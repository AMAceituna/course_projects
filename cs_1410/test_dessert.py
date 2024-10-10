# Dessert Shop Dessert Test Cases

import pytest
from desserts import Candy, Cookie, IceCream, Sundae

# I don't really understand what to make different between this and test_candy.py. Aren't they testing the exact same thing?

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


# stuff for part 3
def test_candy_tax_percent():
    candy = Candy('Candy Bar', 0.5, 1.99)
    assert candy.tax_percent == 7.25

def test_candy_calculate_cost():
    candy = Candy('Candy Bar', 0.5, 1.99)
    assert candy.calculate_cost() == 0.5 * 1.99

def test_candy_calculate_tax():
    candy = Candy('Candy Bar', 0.5, 1.99)
    assert candy.calculate_tax() == 0.5 * 1.99 * (7.25 / 100)

# Stuff for part 5
    
def test_candy_packaging():
    candy = Candy('Pre-Chewed Gum', 9, 9.99)
    assert candy.packaging == "Bag"


if __name__ == "__main__":
    pytest.main()