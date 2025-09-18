import random
from typing import Dict, Any


class Pet:
    SPECIES = ['Dog', 'Cat', 'Bird', 'Fish', 'Rabbit', 'Hamster', 'Guinea Pig']
    NAMES = [
        'Max', 'Buddy', 'Charlie', 'Jack', 'Cooper', 'Rocky', 'Toby', 'Tucker',
        'Jake', 'Bear', 'Duke', 'Teddy', 'Oliver', 'Riley', 'Bailey', 'Bentley',
        'Milo', 'Buster', 'Cody', 'Dexter', 'Winston', 'Murphy', 'Leo', 'Lucky'
    ]
    COLORS = ['Brown', 'Black', 'White', 'Golden', 'Gray', 'Spotted', 'Orange', 'Mixed']

    def __init__(self, name: str, species: str, age: int, color: str, pet_id: int = None):
        self.id = pet_id or random.randint(1000, 9999)
        self.name = name
        self.species = species
        self.age = age
        self.color = color

    @classmethod
    def generate_random(cls) -> 'Pet':
        return cls(
            name=random.choice(cls.NAMES),
            species=random.choice(cls.SPECIES),
            age=random.randint(1, 15),
            color=random.choice(cls.COLORS)
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'name': self.name,
            'species': self.species,
            'age': self.age,
            'color': self.color
        }
