# Payment Module

from typing import Protocol

from enum import Enum

class PayType(Enum):
    CASH = 1
    CARD = 2
    PHONE = 3 # How exactly do you pay with a phone? Is it an iou? Are you financing your sundae?

class Payable(Protocol):

    def get_pay_type(self) -> PayType:
        '''Raise a ValueError if get_pay_type returns anything other than one of these values {CASH, CARD, PHONE}. '''
        pass

    def set_pay_type(self, payment_method:PayType):
        '''Similarly, raise an error if set_pay_type attempts to set a value that is not of of these values.
        {CASH, CARD, PHONE}'''
        pass

# The rubric says:
    # "The Payable Interface is correctly implemented with the get_pay_type() and 
    # set_pay_type(payment_method: PayType) methods. Raises ValueError correctly."
    # About Payable, but that doesn't make sense for a protocol class.
    # In this kind of class we only implement these methods in the concrete stuff that inherets, right?
    # So that stuff should be in Order, shouldn't it?
    # Well that's where I put it.