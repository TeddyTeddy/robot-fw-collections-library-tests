from robot.api.deco import keyword
from robot.api import logger


@keyword
def get_list():
    return ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]


@keyword
def is_dict_in_python(d):
    return  type(d) == dict


@keyword
def get_tuple_with_uniques():
    return 1, 2, 3, 4, 5,


@keyword
def get_tuple_with_duplicates():
    return tuple(get_basic_list())


@keyword
def get_basic_list():
    return ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]


@keyword
def is_list_in_python(l):
    return type(l) == list


@keyword
def get_basic_dictionary():
    return {'key1': 'value1', 'key2': 'value2'}


@keyword
def get_compound_dictionary():
    """
    https://docs.python.org/3/library/copy.html
    An example compound dictionary
    """
    return {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}

@keyword
def get_compound_list():
    """
    https://docs.python.org/3/library/copy.html
    An example compound list
    """
    return [100, {'key1': {'key2':'value'}}]
