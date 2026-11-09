import time
from random import randint
import webbrowser
from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime
from selenium.webdriver.firefox.service import Service

# **Configuration**
FIREFOX_DRIVER_PATH = "/Users/mohitkumar/Downloads/geckodriver"
FIREFOX_PATH = "/Applications/Firefox.app/Contents/MacOS/firefox"

# **Selenium WebDriver Setup**
option = webdriver.FirefoxOptions()
service = Service(executable_path=FIREFOX_DRIVER_PATH)
driver = webdriver.Firefox(service=service, options=option)


# week=r604800
#  day=r86400
#  mnth=r2592000
# **Job Search Settings**
rows_list = []
timeframe = "r86400"  # Last 30 days
keyword_list = ['AWS Engineer','AWS Cloud Engineer', 'Cloud Architect', 'Cloud Data Engineer', 'Cloud Data Engineer',
                'Cloud Data Engineering Lead', 'Cloud Engineer', 'Cloud Lead', 'Cloud Lead Data Engineer',
                'Cloud Senior Data Engineer', 'Cloud Software Engineer', 'Data Consultant', 'Data Engineer',
                'Data Engineer Lead', 'Data Engineering Lead', 'Data Platform Engineer', 'Data Tech Lead',
                'Lead Cloud Solutions Engineer', 'Lead Data Engineer', 'Platform Engineer',
                'Senior Cloud Data Engineer', 'Senior Data Engineer', 'Technical Lead', 'AWS Data Engineer',
                'AWS Data Developer', 'Senior Data Developer', 'Data Consultant', 'AWS Consultant', 'Data Engineer',
                'Cloud Engineer', 'Cloud Consultant', 'Cloud Infrastructure Engineer', 'AWS Platform Engineer',
                'Lead Data Engineer', 'Infrastructure Engineer Cloud', 'aws', 'cloud']
extra_keys = [""]
job_title = []
link_list = []

# **LinkedIn Job Search URLs**
link_listt = [
    "https://www.linkedin.com/jobs/search/?f_TPR={timeframe}&f_JT=C&geoId=90009496&keywords={finalword}&location=London%2C%20England%2C%20United%20Kingdom&refresh=true&sortBy=DD",
    "https://www.linkedin.com/jobs/search/?f_TPR={timeframe}&f_JT=C&geoId=90009497&keywords={finalword}&location=Manchester%20Area%2C%20United%20Kingdom&refresh=true&sortBy=DD",
    "https://www.linkedin.com/jobs/search/?f_TPR={timeframe}&f_JT=C&geoId=101165590&keywords={finalword}&location=Birmingham%2C%20England%2C%20United%20Kingdom&refresh=true&sortBy=DD",
    "https://www.linkedin.com/jobs/search/?f_TPR={timeframe}&f_JT=C&geoId=103024982&keywords={finalword}&location=Leeds%2C%20England%2C%20United%20Kingdom&refresh=true&sortBy=DD",
    "https://www.linkedin.com/jobs/search/?f_TPR={timeframe}&f_JT=C&geoId=90009475&keywords={finalword}&location=Liverpool%2C%20England%2C%20United%20Kingdom&refresh=true&sortBy=DD",
    
]

final_list = []

# **Generate Search Links**
def gen_link():
    try:
        for keyw in keyword_list:
            for extw in extra_keys:
                finalword = "{} {}".format(keyw, extw)
                for linkw in link_listt:
                    try:
                        final_list.append(str(linkw).format(timeframe=timeframe, finalword=finalword))
                    except Exception as e:
                        print(f"Error formatting link: {e}")
        
        # **Scrape LinkedIn Job Listings**
        for flink in final_list:
            if "linkedin" in flink:
                scrape_linkedin_jobs(flink)

    except Exception as e:
        print(f"Error in gen_link: {e}")

# **Scrape LinkedIn Jobs with Pagination**
def scrape_linkedin_jobs(flink):
    page_number = 0
    while True:
        time.sleep(randint(2, 8))
        paginated_url = f"{flink}&start={page_number * 25}"
        driver.get(paginated_url)
        src = driver.page_source
        soup = BeautifulSoup(src, "html.parser")

        # **Extract Job Listings**
        resultscontent = soup.find_all('a', class_='base-card__full-link')
        if not resultscontent:
            break  # **No more jobs, stop pagination**

        for result in resultscontent:
            job = result.get_text().strip()
            link = result['href']
            job_title.append(job)
            if 'view' in link:
                clean_link = link.split("?")[0]
                link_list.append(clean_link)
                rows_list.append({'Role': job, 'link': clean_link})

        page_number += 1  # Move to the next page

# **Save Jobs to CSV**
def final_save():
    df = pd.DataFrame.from_records(rows_list)
    df.to_csv(f"jobs_raw_{datetime.today().strftime('%Y-%m-%d')}.csv", index=False)

    df['Role'] = df['Role'].str.lower()
    print(f"Initial Job Count: {len(df)}")
    df = df.drop_duplicates()

    # **Filtering: Remove unwanted roles & Keep relevant ones**
    discard = ["azure", "gcp", "support", "backend", "sql", "java", "bi", "net", "solicitor", "full-stack","manager", "administrator", "sap", "oracle", "scientist", "rail", "desktop","analytics","server","windows","test","nodejs","grid","vmware","redhat"
               "microsoft", "train", "typescript", "analyst", "web", "blockchain", "back end", "construction","hr", "golang", "m365", "director", "dynamics", "sc ", "salesforce", "sales", "database","security"
               "modeller", "qa engineer","sme","design","system","hvac","quality"
               ]
    
    contains = ["aws", "cloud", "data", "devops", "solution", "engineer", "lead", "consultant"]

    df = df[~df['Role'].astype(str).str.contains('|'.join(discard), case=False)]
    df = df[df['Role'].astype(str).str.contains('|'.join(contains), case=False)]

    df = df.drop_duplicates()
    print(f"Job Count After Filtering: {len(df)}")
    df.to_csv(f"jobs_{datetime.today().strftime('%Y-%m-%d')}.csv", index=False)

# **Sort CSV**
def sort_df():
    df = pd.read_csv(f"jobs_{datetime.today().strftime('%Y-%m-%d')}.csv")
    df = df.sort_values(by=["link"], ascending=False)
    df.to_csv(f"jobs_{datetime.today().strftime('%Y-%m-%d')}.csv", index=False)

# **Chunk & Open Jobs in Browser**
def chunks(lst, n):
    """Yield successive n-sized chunks from list."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

def final_link():
    df = pd.read_csv(f"jobs_{datetime.today().strftime('%Y-%m-%d')}.csv")
    df = df.sort_values(by=["link"], ascending=False)
    urls_list = df["link"]
    new = 2
    x = 0

    for urls in chunks(urls_list, 10):
        for posts in urls:
            webbrowser.register('firefox', None, webbrowser.BackgroundBrowser(FIREFOX_PATH))
            webbrowser.get('firefox').open(posts, new=new)
            x += 1
            if x == 10:
                x = 0

# **Run the Scraper**
if __name__ == '__main__':
    gen_link()
    final_save()
    sort_df()
    final_link()
    driver.quit()  # Close WebDriver
