# Dessert Shop Order Test Cases

'''Add pytest test cases to test the payment type of an Order. Create a new test file test_order.py to hold these test cases. 
You only need 5 test cases: 3 to check for each valid payment type, one to check for trying to set an invalid value and one 
for trying to get (return) an invalid value.
We are not testing the user interface with automated test cases, just Order objects with new payment types.'''

import pytest
from desserts import Order
from payment import PayType


# Valid PayTypes
def test_order_default():
    order = Order()
    assert order.payment_method == PayType.CASH

def test_order_cash():
    order = Order(payment_method=PayType.CASH)
    assert order.payment_method == PayType.CASH

def test_order_card():
    order = Order(payment_method=PayType.CARD)
    assert order.payment_method == PayType.CARD

def test_order_phone():
    order = Order(payment_method=PayType.PHONE)
    assert order.payment_method == PayType.PHONE

# Set an Invalid
def test_order_set_invalid():
    order = Order()
    with pytest.raises(ValueError):
        order.set_pay_type("Pocket lint")

# Return an invalid
def test_order_get_invalid():
    order = Order(payment_method = "Fake pennies")
    with pytest.raises(ValueError):
        order.get_pay_type()


if __name__ == "__main__":
    pytest.main()