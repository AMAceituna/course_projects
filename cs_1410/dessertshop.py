# Dessert Shop Module


from desserts import Candy, Cookie, IceCream, Sundae, Order
import receipt
from payment import PayType


# Dessert Shop Class
class DessertShop():
   def __init__(self):
      pass
   
  # Made validation into methods
   
   # chekc for negative ints
   def get_valid_int(self, prompt):
      while True:
          try:
              value = int(input(prompt))
              if value < 0:
                  raise ValueError("Input must be non-negative.")
              return value
          except ValueError:
              print("Invalid input. Enter a non-negative integer.")

   # check for negative floats
   def get_valid_float(self, prompt):
      while True:
          try:
              value = float(input(prompt))
              if value < 0:
                  raise ValueError("Input must be positive.")
              return value
          except ValueError:
              print("Invalid input. Enter a positive number.")

   # check for empty strings
   def get_valid_str(self, prompt):
      while True:
          value = input(prompt)
          if value.strip():
              return value
          print("Invalid input. Enter a non-empty string.")

   # PayType Validation
   def get_valid_paytype(self, prompt):
      while True:
        payment_method = self.get_valid_str(prompt).upper()
        if payment_method in ("CASH", "CARD", "PHONE"):
            return payment_method
        print("Invalid input. Enter a valid payment method (Cash, Card, or Phone).")


   def user_prompt_candy(self):
     name = self.get_valid_str("Enter the type of candy:")
     quantity = self.get_valid_int("Enter the quantity purchased:")
     price = self.get_valid_float("Enter the price per pound:")
     return(Candy(name, quantity, price))

   def user_prompt_cookie(self):
     name = self.get_valid_str("Enter the type of cookie:")
     quantity = self.get_valid_int("Enter the quantity purchased:")
     price = self.get_valid_float("Enter the price per dozen:")
     return(Cookie(name, quantity, price))
  
   def user_prompt_icecream(self):
     name = self.get_valid_str("Enter the type of ice cream:")
     quantity = self.get_valid_int("Enter the number of scoops:")
     price = self.get_valid_float("Enter the price per scoop:")
     return(IceCream(name, quantity, price))
  
   def user_prompt_sundae(self):
     name = self.get_valid_str("Enter the type of ice cream:")
     quantity = self.get_valid_int("Enter the number of scoops:")
     price = self.get_valid_float("Enter the price per scoop:")
     topping_name = self.get_valid_str("Enter the topping:")
     topping_price = self.get_valid_float("Enter the price for the topping:")
     return(Sundae(f"{name} Sundae", quantity, price, topping_name, topping_price))
   
   def user_prompt_payment_method(self):
      payment_method = self.get_valid_paytype("Enter payment method (Cash, Card, or Phone):")
      return(PayType[payment_method])


# Main
def main():
  shop = DessertShop() 
  order = Order()
  '''
  order.add(Candy('Candy Corn', 1.5, 0.25))
  order.add(Candy('Gummy Bears', 0.25, 0.35))
  order.add(Cookie('Chocolate Chip', 6, 3.99))
  order.add(IceCream('Pistachio', 2, 0.79))
  order.add(Sundae('Vanilla', 3, 0.69, 'Hot Fudge', 1.29))
  order.add(Cookie('Oatmeal Raisin', 2, 3.45))
  '''
  # boolean done = false
  done: bool = False
  # build the prompt string once
  prompt = '\n'.join([ '\n',
          '1: Candy',
          '2: Cookie',            
          '3: Ice Cream',
          '4: Sunday',
          '\nWhat would you like to add to the order? (1-4, Enter for done): '
    ])

  while not done:
    choice = input(prompt)
    match choice:
      case '':
        order.payment_method = shop.user_prompt_payment_method()
        done = True
      case '1':            
        item = shop.user_prompt_candy()
        order.add(item)
        # print(f'{item.name} has been added to your order.')
        print(order)
      case '2':            
        item = shop.user_prompt_cookie()
        order.add(item)
        # print(f'{item.name} has been added to your order.')
        print(order)
      case '3':            
        item = shop.user_prompt_icecream()
        order.add(item)
        # print(f'{item.name} has been added to your order.')
        print(order)
      case '4':            
        item = shop.user_prompt_sundae()
        order.add(item)
        # print(f'{item.name} has been added to your order.')
        print(order)
      case _:            
        print('Invalid response:  Please enter a choice from the menu (1-4) or Enter')
  print()

#add your code below here to print the PDF receipt as the last thing in main()

  # loop for receipt list
  data = []
  data.append(["Name", "Quantity", "Unit Price", "Item Cost", "Tax"]) # Title Row
  for item in order:

    # Trying to get the receipt to work was a nightmare.
    if isinstance(item, Sundae):
        # Split the __str__ result into two parts
        sundae_parts = item.__str__().split(',')
        data.append(sundae_parts[:5])  # Append icecream part
        data.append([sundae_parts[5],'1', sundae_parts[6],'',sundae_parts[-1]])  # Append topping part
    else:
        data.append(item.__str__().split(','))

  # receipt subtotal and total tax row
  data.append(['-------------------------','-----','-----','-----','-----']) # Add a spacer to make it look nicer

   # receipt total item # row
  data.append(["Total items in the order:", len(order),' ',' ',' '])

  subtotal = 0
  for item in order:
     subtotal += item.calculate_cost()

  total_tax = 0
  for item in order:
     total_tax += item.calculate_tax()

  data.append(["Order Subtotals:",'','', f"${subtotal:.2f}", f"[Tax: ${total_tax:.2f}]"])

  # receipt total cost (subtotal + total tax) row
  data.append(["Order Total:", '','','', f"${(subtotal + total_tax):.2f}"])

  # add payment type to receipt
  data.append(['-------------------------','-----','-----','-----','-----']) # Guess we added another spacer
  payment_method_str = ""
  if order.payment_method == PayType.CASH:
      payment_method_str = "CASH"
  elif order.payment_method == PayType.CARD:
      payment_method_str = "CARD"
  elif order.payment_method == PayType.PHONE:
      payment_method_str = "PHONE"  # It's very annoying that self.payment_method gives "PayType.CASH" instead of CASH
  data.append([f"Paid with {payment_method_str}",'','','',''])


  # Do we even still want this? The receipts look completely different from what it puts out.
  # But part 8 switches back to this style.
  # I'm going to just pretend that it's supposed to be this style.
  receipt.make_receipt(data, "receipt.pdf")

  # testing order's __str__()
  # print(order.__str__())
  # I'm not really understanding what we want out of __str__

if __name__ == "__main__":
    main()
