import random
import string

def generate_random_password(length=12):
    # Define the possible characters for the password
    uppercase_letters = string.ascii_uppercase
    lowercase_letters = string.ascii_lowercase
    digits = string.digits
    special_characters = string.punctuation
    
    # Ensure the password contains at least one character from each category
    password = [
        random.choice(uppercase_letters),
        random.choice(lowercase_letters),
        random.choice(digits),
        random.choice(special_characters)
    ]
    
    # Fill the rest of the password length with random choices from all categories
    all_characters = uppercase_letters + lowercase_letters + digits + special_characters
    password += random.choices(all_characters, k=length-4)
    
    # Shuffle the resulting password list to avoid predictable patterns
    random.shuffle(password)
    
    # Convert the list to a string and return it
    return ''.join(password)


if __name__ == '__main__':
    pass