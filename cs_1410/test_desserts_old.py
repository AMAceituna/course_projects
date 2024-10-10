# Dessert Shop Test Cases

import pytest
from desserts import Candy, Cookie, IceCream, Sundae

# Candy
def test_candy_default():
    candy = Candy()
    assert candy.name == ''
    assert candy.weight == 0.0
    assert candy.price_per_pound == 0.0

def test_candy_custom():
    candy = Candy('Candy Bar', 0.5, 1.99)
    assert candy.name == 'Candy Bar'
    assert candy.weight == 0.5
    assert candy.price_per_pound == 1.99

def test_candy_change():
    candy = Candy('Candy Bar', 0.5, 1.99)
    assert candy.name == 'Candy Bar'
    assert candy.weight == 0.5
    assert candy.price_per_pound == 1.99

    candy.weight = 1.5
    assert candy.weight == 1.5

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

# IceCream
def test_icecream_default():
    icecream = IceCream()
    assert icecream.name == ''
    assert icecream.scoop_count == 0
    assert icecream.price_per_scoop == 0.0

def test_icecream_custom():
    icecream = IceCream('Vanilla', 1, 1.99)
    assert icecream.name == 'Vanilla'
    assert icecream.scoop_count == 1
    assert icecream.price_per_scoop == 1.99

def test_icecream_change():
    icecream = IceCream('Vanilla', 1, 1.99)
    assert icecream.name == 'Vanilla'
    assert icecream.scoop_count == 1
    assert icecream.price_per_scoop == 1.99

    icecream.scoop_count = 2
    assert icecream.scoop_count == 2

# Sundae
def test_sundae_default():
    sundae = Sundae()
    assert sundae.name == ''
    assert sundae.scoop_count == 0
    assert sundae.price_per_scoop == 0.0
    assert sundae.topping_name == ''
    assert sundae.topping_price == 0.0

def test_sundae_custom():
    sundae = Sundae('Chocolate Sundae', 2, 2.99, 'Sprinkles', 0.50)
    assert sundae.name == 'Chocolate Sundae'
    assert sundae.scoop_count == 2
    assert sundae.price_per_scoop == 2.99
    assert sundae.topping_name == 'Sprinkles'
    assert sundae.topping_price == 0.50

def test_sundae_change():
    sundae = Sundae('Chocolate Sundae', 2, 2.99, 'Sprinkles', 0.50)
    assert sundae.name == 'Chocolate Sundae'
    assert sundae.scoop_count == 2
    assert sundae.price_per_scoop == 2.99
    assert sundae.topping_name == 'Sprinkles'
    assert sundae.topping_price == 0.50

    sundae.scoop_count = 3
    assert sundae.scoop_count == 3

    sundae.topping_price = 1.00
    assert sundae.topping_price == 1.00


if __name__ == "__main__":
    pytest.main()