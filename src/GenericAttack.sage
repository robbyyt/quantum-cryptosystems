from abc import ABC, abstractmethod

class GenericAttack(ABC):
    def __init__(self, H, syndrome, t):
        self.H = H
        self.syndrome = syndrome
        self.t = t

    @abstractmethod
    def attack(self):
        ...
