# Dessert Shop 0

class Candy:
  def __init__(self, name = '', weight = 0.0, price_per_pound = 0.0):
    self.name = name
    self.weight = weight
    self.price_per_pound = price_per_pound

class Cookie:
  def __init__(self, name = '', quantity = 0, price_per_dozen = 0.0):
    self.name = name
    self.quantity = quantity
    self.price_per_dozen = price_per_dozen

class IceCream:
  def __init__(self, name = '', scoop_count = 0, price_per_scoop = 0.0):
    self.name = name
    self.scoop_count = scoop_count
    self.price_per_scoop = price_per_scoop

class Sundae:
  def __init__(self, name = '', scoop_count = 0, price_per_scoop = 0.0, topping_name = "", topping_price = 0.0):
    self.name = name
    self.scoop_count = scoop_count
    self.price_per_scoop = price_per_scoop
    self.topping_name = topping_name
    self.topping_price = topping_price

