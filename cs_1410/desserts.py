# Dessert Shop

from abc import ABC, abstractmethod
from packaging import Packaging
from payment import PayType, Payable

# Superclass
class DessertItem(ABC, Packaging):
  def __init__(self, name:str = '', tax_percent:float = 7.25, packaging:str = None):
    self.name = name
    self.tax_percent = tax_percent
    self.packaging = packaging # "Do not change the constructor signature, because you can create a dessert
                              # and add packaging later. Default value is None."
                              # Idk how you would make this without modifying the signature by putting in packaging:str = None.
                              # Maybe the directions are perfectly clear and I'm missing something obvious.

  @abstractmethod
  def calculate_cost(self) -> float:
    pass

  def calculate_tax(self):
    return self.calculate_cost() * (self.tax_percent/100)



# Primary Subclasses (concrete)
  
# Candy
class Candy(DessertItem):
  def __init__(self, name:str = '', weight:float = 0.0, price_per_pound:float = 0.0):
    super().__init__(name)
    self.weight = weight
    self.price_per_pound = price_per_pound
    self.packaging = "Bag"

  def __str__(self):
    return(f"{self.name} ({self.packaging}), {self.weight} lbs, ${self.price_per_pound:.2f}/lbs, ${self.calculate_cost():.2f}, [Tax: ${self.calculate_tax():.2f}]")
    # I made the tax part look more like the sample receipt, but ngl it's uuuuugly
  
  def calculate_cost(self):
    return self.weight * self.price_per_pound

# Cookie
class Cookie(DessertItem):
  def __init__(self, name:str = '', quantity:int = 0, price_per_dozen:float = 0.0):
    super().__init__(name)
    self.quantity = quantity
    self.price_per_dozen = price_per_dozen
    self.packaging = "Box"

  def __str__(self):
    return(f"{self.name} ({self.packaging}), {self.quantity} cookies, ${self.price_per_dozen:.2f}/dozen, ${self.calculate_cost():.2f}, [Tax: ${self.calculate_tax():.2f}]")

  def calculate_cost(self):
    return (self.quantity/12) * self.price_per_dozen

# Ice Cream
class IceCream(DessertItem):
  def __init__(self, name:str = '', scoop_count:int = 0, price_per_scoop:float = 0.0):
    super().__init__(name)
    self.scoop_count = scoop_count
    self.price_per_scoop = price_per_scoop
    self.packaging = "Bowl"

  def __str__(self):
    return(f"{self.name} ({self.packaging}), {self.scoop_count} scoops, ${self.price_per_scoop:.2f}/scoop, ${self.calculate_cost():.2f}, [Tax: ${self.calculate_tax():.2f}]")

  def calculate_cost(self):
    return self.scoop_count * self.price_per_scoop


# Secondary Subclass
  
# Sundae
class Sundae(IceCream):
  def __init__(self, name:str = '', scoop_count:int = 0, price_per_scoop:float = 0.0, topping_name:str = "", topping_price:float = 0.0):
    super().__init__(name, scoop_count, price_per_scoop)
    self.topping_name = topping_name
    self.topping_price = topping_price
    self.packaging = "Boat"

  def __str__(self):
    return(f"{self.name} sundae ({self.packaging}), {self.scoop_count} scoops, ${self.price_per_scoop:.2f}/scoop, ${self.calculate_cost():.2f}, ,"
           f"{self.topping_name} topping, ${self.topping_price:.2f}, , [Tax: ${self.calculate_tax():.2f}]")

  def calculate_cost(self):
    return self.scoop_count * self.price_per_scoop + self.topping_price



# Order Container Class
class Order(Payable):
  def __init__(self, order:list[DessertItem] = [], payment_method:PayType = PayType.CASH):
    self.order = order
    # if payment_method not in (PayType.CASH, PayType.CARD, PayType.PHONE):
    #         raise ValueError("Invalid payment method")
    self.payment_method = payment_method

  def add(self, new_item:DessertItem):
    self.order.append(new_item)

  def get_pay_type(self) -> PayType:
      if self.payment_method not in (PayType.CASH, PayType.CARD, PayType.PHONE):
          raise ValueError("Invalid payment method {CASH, CARD, PHONE}")
      return self.payment_method

  def set_pay_type(self, payment_method: PayType):
      if payment_method not in (PayType.CASH, PayType.CARD, PayType.PHONE):
          raise ValueError("Invalid payment method {CASH, CARD, PHONE}")
      self.payment_method = payment_method

  def __len__(self):
    return len(self.order)
  
  def __iter__(self):
    self.index = 0
    return self

  def __next__(self):
      if self.index < len(self.order):
          current_item = self.order[self.index]
          self.index += 1
          return current_item
      else:
          self.index = 0
          raise StopIteration
      
  def order_cost(self):
    total_cost = 0
    for i in self.order:
      total_cost += i.calculate_cost
    return total_cost

  def order_tax(self):
    total_tax = 0
    for i in self.order:
      total_tax += i.calculate_tax
    return total_tax
  
  # def __str__(self):
  #   for i in self.order:
  #           return(i.__str__())
    
  def __str__(self):
    order_str = '\n'.join([item.__str__() for item in self.order])

    payment_method_str = ""
    if self.payment_method == PayType.CASH:
        payment_method_str = "CASH"
    elif self.payment_method == PayType.CARD:
        payment_method_str = "CARD"
    elif self.payment_method == PayType.PHONE:
        payment_method_str = "PHONE"  # It's very annoying that self.payment_method gives "PayType.CASH" instead of CASH

    return order_str + f", Paid with {payment_method_str}"


