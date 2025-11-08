import csv
import time
from dataclasses import dataclass, asdict
from typing import List
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup


HEADERS = {
    # Pretend to be a normal browser to avoid being blocked on simple sites
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    )
}


@dataclass
class Profile:
    url: str
    site: str
    name: str
    headline: str
    location: str
    about: str


def load_urls(path: str = "urls.txt") -> List[str]:
    urls = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                urls.append(line)
    return urls


def fetch_html(url: str) -> str:
    """
    Download the HTML for a given URL.

    For sites that require login (like LinkedIn), you would instead
    use Selenium with a logged-in test account. This function is
    intentionally simple and only works for public pages.
    """
    response = requests.get(url, headers=HEADERS, timeout=20)
    response.raise_for_status()
    return response.text


def parse_profile(url: str, html: str) -> Profile:
    """
    Very generic parser that tries to infer:
    - name from <h1> or first <title>
    - headline from <h2> or part of <title>
    - location from elements containing words like 'Location'
    - about from a section with 'About' heading

    You can adjust selectors once you pick your actual target pages.
    """
    soup = BeautifulSoup(html, "html.parser")
    parsed_url = urlparse(url)

    # Name
    name_tag = soup.find("h1")
    if name_tag and name_tag.get_text(strip=True):
        name = name_tag.get_text(strip=True)
    else:
        # Fallback: first part of <title>
        title_tag = soup.find("title")
        if title_tag and title_tag.get_text(strip=True):
            name = title_tag.get_text(strip=True).split("|")[0].strip()
        else:
            name = ""

    # Headline
    headline_tag = soup.find("h2")
    headline = headline_tag.get_text(strip=True) if headline_tag else ""

    # Location (very heuristic)
    location = ""
    for tag in soup.find_all(["span", "div"]):
        text = tag.get_text(" ", strip=True)
        if "location" in text.lower():
            location = text
            break

    # About section (look for heading containing 'About')
    about = ""
    for heading in soup.find_all(["h2", "h3", "h4"]):
        if "about" in heading.get_text(strip=True).lower():
            # Take the next sibling block as about text
            sib = heading.find_next_sibling()
            if sib:
                about = sib.get_text(" ", strip=True)
            break

    return Profile(
        url=url,
        site=parsed_url.netloc,
        name=name,
        headline=headline,
        location=location,
        about=about,
    )


def save_profiles_csv(profiles: List[Profile], path: str = "profiles.csv") -> None:
    if not profiles:
        print("No profiles to save.")
        return

    fieldnames = list(asdict(profiles[0]).keys())
    with open(path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for profile in profiles:
            writer.writerow(asdict(profile))

    print(f"Saved {len(profiles)} profiles to {path}")


def main() -> None:
    urls = load_urls()
    print(f"Loaded {len(urls)} URLs")

    profiles: List[Profile] = []

    for i, url in enumerate(urls, start=1):
        try:
            print(f"[{i}/{len(urls)}] Fetching {url}")
            html = fetch_html(url)
            profile = parse_profile(url, html)
            profiles.append(profile)
            # Small delay to be polite
            time.sleep(1)
        except Exception as e:
            print(f"Error fetching {url}: {e}")

    save_profiles_csv(profiles)


if __name__ == "__main__":
    main()
