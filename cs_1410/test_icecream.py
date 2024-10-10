# Dessert Shop ice cream Test Cases

import pytest
from desserts import Candy, Cookie, IceCream, Sundae


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


# tests for part 3
def test_icecream_tax_percent():
    icecream = IceCream('Vanilla', 1, 1.99)
    assert icecream.tax_percent == 7.25

def test_icecream_calculate_cost():
    icecream = IceCream('Vanilla', 1, 1.99)
    assert icecream.calculate_cost() == 1 * 1.99

def test_icecream_calculate_tax():
    icecream = IceCream('Vanilla', 1, 1.99)
    assert icecream.calculate_tax() == (1 * 1.99) * (7.25 / 100)


# Stuff for part 5
    
def test_icecream_packaging():
    icecream = IceCream('De-iced Cream', 9, 9.99)
    assert icecream.packaging == "Bowl"


if __name__ == "__main__":
    pytest.main()