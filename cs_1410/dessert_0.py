# Dessert Shop 01

# Superclass
class DessertItem:
  def __init__(self, name:str = ''):
    self.name = name


# Primary Subclasses
class Candy(DessertItem):
  def __init__(self, name:str = '', weight:float = 0.0, price_per_pound:float = 0.0):
    super().__init__(name)
    self.weight = weight
    self.price_per_pound = price_per_pound

class Cookie(DessertItem):
  def __init__(self, name:str = '', quantity:int = 0, price_per_dozen:float = 0.0):
    super().__init__(name)
    self.quantity = quantity
    self.price_per_dozen = price_per_dozen

class IceCream(DessertItem):
  def __init__(self, name:str = '', scoop_count:int = 0, price_per_scoop:float = 0.0):
    super().__init__(name)
    self.scoop_count = scoop_count
    self.price_per_scoop = price_per_scoop


# Secondary Subclasses
class Sundae(IceCream):
  def __init__(self, name:str = '', scoop_count:int = 0, price_per_scoop:float = 0.0, topping_name:str = "", topping_price:float = 0.0):
    super().__init__(name, scoop_count, price_per_scoop)
    self.topping_name = topping_name
    self.topping_price = topping_price

