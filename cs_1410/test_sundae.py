# Dessert Shop Sundae Test Cases

import pytest
from desserts import Candy, Cookie, IceCream, Sundae


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


# tests for part 3
def test_sundae_tax_percent():
    sundae = Sundae('Chocolate Sundae', 2, 2.99, 'Sprinkles', 0.50)
    assert sundae.tax_percent == 7.25

def test_sundae_calculate_cost():
    sundae = Sundae('Chocolate Sundae', 2, 2.99, 'Sprinkles', 0.50)
    assert sundae.calculate_cost() == (2 * 2.99) + 0.50    # add cost of the topping

def test_sundae_calculate_tax():
    sundae = Sundae('Chocolate Sundae', 2, 2.99, 'Sprinkles', 0.50)
    assert sundae.calculate_tax() == ((2 * 2.99) + 0.50) * (7.25 / 100)    # add the topping here too


# Stuff for part 5
    
def test_sundae_packaging():
    sundae = Sundae('De-iced Cream', 9, 9.99, 'Pre-Chewed Gum', .99)
    assert sundae.packaging == "Boat"

if __name__ == "__main__":
    pytest.main()