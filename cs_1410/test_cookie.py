# Dessert Shop Cookie Test Cases

import pytest
from desserts import Candy, Cookie, IceCream, Sundae


# Cookie
def test_cookie_default():
    cookie = Cookie()
    assert cookie.name == ''
    assert cookie.quantity == 0
    assert cookie.price_per_dozen == 0.0

def test_cookie_custom():
    cookie = Cookie('Chocolate Chip', 12, 4.99)
    assert cookie.name == 'Chocolate Chip'
    assert cookie.quantity == 12
    assert cookie.price_per_dozen == 4.99

def test_cookie_change():
    cookie = Cookie('Chocolate Chip', 12, 4.99)
    assert cookie.name == 'Chocolate Chip'
    assert cookie.quantity == 12
    assert cookie.price_per_dozen == 4.99

    cookie.quantity = 13
    assert cookie.quantity == 13


# tests for part 3
def test_cookie_tax_percent():
    cookie = Cookie('Chocolate Chip', 12, 4.99)
    assert cookie.tax_percent == 7.25

def test_cookie_calculate_cost():
    cookie = Cookie('Chocolate Chip', 12, 4.99)
    assert cookie.calculate_cost() == 12 * (4.99 / 12)  # makes it price per cookie

def test_cookie_calculate_tax():
    cookie = Cookie('Chocolate Chip', 12, 4.99)
    assert cookie.calculate_tax() == (12 * (4.99 / 12)) * (7.25 / 100)


# Stuff for part 5
    
def test_cookie_packaging():
    cookie = Cookie('Pancake', 9, 9.99)
    assert cookie.packaging == "Box"

if __name__ == "__main__":
    pytest.main()