from requests import get
from requests.exceptions import RequestException
from contextlib import closing
from bs4 import BeautifulSoup
import re
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import random


def init_firebase():
    cred = credentials.Certificate("newsportal-c9806-firebase-adminsdk-p2o93-672878117b.json")
    firebase_admin.initialize_app(cred,{
        'databaseURL': 'https://newsportal-c9806.firebaseio.com/'
    })


def simple_get(url):
    """
    Attempts to get the content at `url` by making an HTTP GET request.
    If the content-type of response is some kind of HTML/XML, return the
    text content, otherwise return None.
    """
    try:
        with closing(get(url, stream=True)) as resp:
            if is_good_response(resp):
                return resp.content
            else:
                return None

    except RequestException as e:
        log_error('Error during requests to {0} : {1}'.format(url, str(e)))
        return None


def is_good_response(resp):
    """
    Returns True if the response seems to be HTML, False otherwise.
    """
    content_type = resp.headers['Content-Type'].lower()
    return (resp.status_code == 200
            and content_type is not None
            and content_type.find('html') > -1)


def log_error(e):
    """
    It is always a good idea to log errors.
    This function just prints them, but you can
    make it do anything.
    """
    print(e)


def save_new(image, title, author, content, category, create_date):
    root = db.reference()
    root.child("news").push({
        'title': title,
        'author': author,
        'image': image,
        'content': content,
        'category_id': category,
        'create': create_date
    })


def updateCategories():
    root = db.reference()
    categories = root.child("categories").get()
    numbers = {}
    for key, val in categories.items():
        numbers[key] = 0
    news = root.child("news").get()
    for news_key, news_val in news.items():
        category_id = news_val["category_id"]
        numbers[category_id] = numbers[category_id] + 1
    print(numbers)
    for key, number in numbers.items():
        root.child("categories").child(key).update({
            "count": number,
        })


def init_categories():
    categories = ["Politics", "Sports", "Finance", "Lifestyle"]
    root = db.reference()
    for category in categories:
        root.child("categories").push({
            'name': category
        })


def get_categories():
    root = db.reference('categories')
    return root.get()


if __name__ == '__main__':
    init_firebase()
    categories = get_categories()
    category_ids = list(categories.keys())
    page = simple_get('https://totalcar.hu');
    html = BeautifulSoup(page, 'html.parser')
    blocks = html.findAll("div", {"class":"blokk-hasab"})

    for block in blocks:
        img_cont = block.findAll("img", {"class":"cikkep"})
        img = re.match("//.", img_cont[0]['src'])
        if img is not None:
            img = "http:" + img.string
            span_cont = block.findAll("span")
            title_cont = block.findAll("h1", {"class": "cikkcim"})
            if len(title_cont) == 1:
                title = title_cont[0].text.strip()
                new_href = title_cont[0].findAll('a')[0]['href']
                new_page = simple_get(new_href)
                new_html = BeautifulSoup(new_page,'html.parser')
                author = new_html.findAll("a",{"rel":"author"})
                if len(author) == 1:
                    author = author[0].string
                    content = ""
                    contents = new_html.findAll("p")
                    for c in contents:
                        if c.string is not None:
                            content += c.string
                    creat_date = new_html.findAll("div",{"class":"datum"})[0].findAll("span")[0].string
                    category_id = random.choice(category_ids)
                    save_new(img, title, author, content, category_id, creat_date)

    updateCategories()
