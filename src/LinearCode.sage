from abc import ABC, abstractmethod

class LinearCode(ABC):
    def __init__(self, code=None):
        self.code = code

    def set_code(self, code):
        self.code = code

    def get_code(self):
        return self.code

    @abstractmethod
    def get_parity_check_matrix(self):
        ...

    @staticmethod
    def serialize_instance(self, target_file_name):
        pass

    @staticmethod
    def load_from_file(self):
        pass
