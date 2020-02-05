*** Settings ***
Documentation    A test suite utilizing all collection library keywords
Library          Collections
Library          Utils.py

# To run:
# robot  --pythonpath Resources --noncritical failure-expected -d Results/  Tests/collection-library-tests.robot

*** Keywords ***

*** Test Cases ***
Use "Append To List"
    [Documentation]     Append To List 	list_, *values
    ...                 Adds values to the end of list.
    ${l1} =     Create List     a
    ${l1_expected} =    Create List     @{l1}   xxx
    Append To List 	${l1} 	xxx         # test
    Should Be Equal     ${l1}       ${l1_expected}      # passes

    ${l2} =     Create List     a   b
    ${l2_expected} =        Create List     @{l2}     x     y     z
    Append To List 	${l2} 	x 	y 	z       # test
    Should Be Equal   ${l2}     ${l2_expected}          # passes

Use "Combine Lists"
    [Documentation]     Combine Lists 	*lists
    ...                 Combines the given lists together and returns the result.
    ...                 The given lists are not altered by this keyword.
    ${l1} =     Create List     a
    ${l1_unchanged} =   Create List     @{l1}
    ${l2} =     Create List     a   b
    ${l2_unchanged} =   Create List     @{l2}

    # test
    ${x} =      Combine Lists   ${l1}   ${l2}
    ${y} =      Combine Lists   ${l1}   ${l2}   ${l1}

    # verify
    Should Be True     $x == ['a', 'a', 'b']        # passes
    Should Be True     $y == ['a', 'a', 'b', 'a']   # passes
    Should Be Equal     ${l1}     ${l1_unchanged}   # passes
    Should Be Equal     ${l2}     ${l2_unchanged}   # passes

Use "Convert To (Python) Dictionary"
    [Documentation]     Converts the given item to a Python dict type.
    ...                 Mainly useful for converting other mappings to normal dictionaries. This includes
    ...                 converting Robot Framework's own DotDict instances that it uses if variables are created
    ...                 using the &{var} syntax.
    ...                 Use Create Dictionary from the BuiltIn library for constructing new dictionaries.
    ...                 New in Robot Framework 2.9.
    &{robot_dot_dict} =     Create Dictionary   key=value   # a Dot Dict, not a Python Dict
    ${isDict} =     is dict in python   ${robot_dot_dict}
    Should Not Be True     ${isDict}

    # test
    ${python_dict} =    Convert To Dictionary   ${robot_dot_dict}

    # verify
    ${isDict} =     is dict in python   ${python_dict}
    Should Be True     ${isDict}        # passes

Use "Convert (An Iterable) To (Python) List"
    [Documentation]     Convert To List 	item
    ...                 Converts the given item to a Python list type.
    ...                 Mainly useful for converting tuples, dictionaries and other iterable to lists.
    # with tuples
    ${python_tuple} =   get tuple with duplicates  # from Utils.py; ('a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1, )
    @{robot_list} =     Convert To List    ${python_tuple}  # test
    ${isList} =         is list in python   ${robot_list}
    Should Be True      ${isList}  # passes
    Should Be True      $robot_list == ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1, ]     # passes

    # with dictionaries
    ${python_dict} =    get basic dictionary      # from Utils.py; {'key1': 'value1', 'key2': 'value2'}
    @{expected_list} =  Create List     key1    key2
    @{robot_list} =     Convert To List     ${python_dict}  # test
    Should Be Equal     ${expected_list}    ${robot_list}   # passes

Use "Copy Dictionary" : Shallow Copy
    [Documentation]     https://stackoverflow.com/questions/60004029/robot-fw-collections-library-copy-dictionary-how-to-make-a-shallow-copy/60008236?noredirect=1#comment106158779_60008236
    ...                 Fails, why?
    [Tags]              not-understood

    ${original_dictionary} =     get compound dictionary     # from Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    &{shallow_copy} =   Copy Dictionary     ${original_dictionary}       deepcopy=${False}

    # if we modify the contained objects (i.e. deep_dict) through the shallow_copy,
    # the original original_dictionary will see the changes in the contained objects
    Set To Dictionary    ${shallow_copy}[deep_dict]     key2=modified
    Should Be True     $shallow_copy == {'key1': 'value1', 'deep_dict': {'key2': 'modified'}}
    Should Be True     $original_dictionary == {'key1': 'value1', 'deep_dict': {'key2': 'modified'}}

Use "Copy Dictionary" : Deep Copy
    ${original_dictionary} =     get compound dictionary     # from Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    &{deep_copy} =   Copy Dictionary     ${original_dictionary}       deepcopy=${True}

    # deep_copy will have its own instances of the contained objects
    # if we modify the contained objects (i.e. deep_dict) through the deep_copy,
    # the original original_dictionary will NOT see the changes in its version of the contained objects
    Set To Dictionary    ${deep_copy}[deep_dict]     key2=modified
    Should Be Equal      ${deep_copy}[deep_dict][key2]       modified            # passes
    Should Be Equal      ${original_dictionary}[deep_dict][key2]       value2    # passes

Use "Copy List" : Shallow Copy
    [Documentation]     Copy List 	list_, deepcopy=False
    ...                 Returns a copy of the given list.
    ...                 If the optional deepcopy is given a true value, the returned list is a deep copy.
    ...                 New option in Robot Framework 3.1.2.
    ...                 The given list is never altered by this keyword
    @{original_list} =    get compound list   # from Utils.py;  [100, {'key1': {'key2':'value'}}]
    @{shallow_copy} =   Copy List   ${original_list}      deepcopy=${False}

    # the shallow_copy will share the contained objects (i.e. {'key2':'value'} ) with original_list
    # the nested contained objects modified via the shallow_copy will be accessible by original_list;
    # the modifications to the nested contained objects will be visible via  original_list
    Set To Dictionary    ${shallow_copy}[1][key1]   key2=modified
    Should Be Equal      ${shallow_copy}[1][key1][key2]     modified             # passes
    Should Be Equal      ${original_list}[1][key1][key2]    modified             # passes

Use "Copy List" : Deep Copy
    [Documentation]     Copy List 	list_, deepcopy=False
    ...                 Returns a copy of the given list.
    ...                 If the optional deepcopy is given a true value, the returned list is a deep copy.
    ...                 New option in Robot Framework 3.1.2.
    ...                 The given list is never altered by this keyword
    @{original_list} =    get compound list   # from Utils.py;  [100, {'key1': {'key2':'value'}}]
    @{deep_copy} =   Copy List   ${original_list}      deepcopy=${True}

    # the deep_copy will have its own copy of the contained objects (i.e. {'key2':'value'} ) seperated from original_list
    # the nested contained objects modified via deep_copy will NOT modify the contained object in original_list
    # the modifications will NOT be visible via original_list
    Set To Dictionary    ${deep_copy}[1][key1]   key2=modified
    Should Be Equal      ${deep_copy}[1][key1][key2]     modified                # passes
    Should Be Equal      ${original_list}[1][key1][key2]     value               # passes

Use "Count Values In List"
    [Documentation]     Count Values In List 	list_, value, start=0, end=None
    ...                 Returns the number of occurrences of the given 'value' in 'list'.
    ...                 The search can be narrowed to the selected sublist by the start and end indexes having the same
    ...                 semantics as with Get Slice From List keyword. The given list is never altered by this keyword.
    @{lst} =            get list  # from Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${count} =          Count Values In List     list_=${lst}   value=a
    Should Be Equal     ${count}    ${2}

    @{lst} =            get list  # from Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${count} =          Count Values In List     list_=${lst}   value=a     start=3     end=None
    Should Be Equal     ${count}    ${0}

Use "Dictionaries Should Be Equal"
    [Documentation]     Dictionaries Should Be Equal 	dict1, dict2, msg=None, values=True
    ...                 The types of the dictionaries do not need to be same.
    [Tags]              failure-expected
    ${python_dict} =     get basic dictionary   # Resources/Utils.py; {'key1': 'value1', 'key2': 'value2'}
    ${dot_dict} =       Create Dictionary      key1=value1      key2=value2
    Dictionaries Should Be Equal    ${python_dict}      ${dot_dict}     msg=Wont show as no error    values=${True}  # test

    # observation: even though dictionary items are not in the same order, the keyword passes
    ${dot_dict} =       Create Dictionary      key2=value2      key1=value1  # items swapped
    Dictionaries Should Be Equal    ${python_dict}      ${dot_dict}     msg=Wont show as no error    values=${True}  # test

    ${dot_dict} =       Create Dictionary      key1=different      key3=different  # items swapped
    Run Keyword And Ignore Error    Dictionaries Should Be Equal    ${python_dict}      ${dot_dict}     msg=Error msg show as error    values=${True}  # test

Use "Dictionary Should Contain Item"
    [Documentation]      Dictionary Should Contain Item 	dictionary, key, value, msg=None
    [Tags]               failure-expected
    ${python_dict} =     get basic dictionary   # Resources/Utils.py; {'key1': 'value1', 'key2': 'value2'}
    Dictionary Should Contain Item      ${python_dict}      key2    value2      msg=Wont show as no error  # test
    Run Keyword And Ignore Error    Dictionary Should Contain Item   ${python_dict}      key2    not found      msg=Error msg will show

Use "Dictionary Should Contain Key"
    [Documentation]     Dictionary Should Contain Key 	dictionary, key, msg=None
    [Tags]              failure-expected
    ${python_dict} =    get basic dictionary   # Resources/Utils.py; {'key1': 'value1', 'key2': 'value2'}
    Dictionary Should Contain Key   ${python_dict}      key1  # test
    Run Keyword And Ignore Error    Dictionary Should Contain Key   ${python_dict}      key3    # test

Use "Dictionary Should Contain Sub Dictionary"
    [Documentation]     Dictionary Should Contain Sub Dictionary 	dict1, dict2, msg=None, values=True
    ...                 Fails unless all items in dict2 are found from dict1.
    [Tags]              failure-expected
    ${compound_dict} =  get compound dictionary  # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    ${basic_dict} =     Create Dictionary        key2=value2
    ${sub_dict} =       Create Dictionary        deep_dict   ${basic_dict}
    # test
    Run Keyword And Ignore Error    Dictionary Should Contain Sub Dictionary    dict1=${compound_dict}    dict2=${basic_dict}
    Dictionary Should Contain Sub Dictionary    dict1=${compound_dict}    dict2=${sub_dict}

Use "Dictionary Should Contain Value"
    [Documentation]     Dictionary Should Contain Value 	dictionary, value, msg=None
    [Tags]              failure-expected
    ${compound_dict} =  get compound dictionary  # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    ${basic_dict} =     Create Dictionary        key2=value2
    # test
    Dictionary Should Contain Value     ${compound_dict}    ${basic_dict}
    Run Keyword And Ignore Error        Dictionary Should Contain Value     ${compound_dict}        X

Use "Dictionary Should Not Contain Key"
    [Documentation]     Dictionary Should Not Contain Key 	dictionary, key, msg=None
    [Tags]              failure-expected
    ${compound_dict} =  get compound dictionary  # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    # *** test cases ***
    Dictionary Should Not Contain Key   ${compound_dict}    keyX
    Run Keyword And Ignore Error        Dictionary Should Not Contain Key   ${compound_dict}    deep_dict

Use "Dictionary Should Not Contain Value"
    [Documentation]     Dictionary Should Not Contain Value 	dictionary, value, msg=None
    [Tags]              failure-expected
    ${compound_dict} =  get compound dictionary  # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    ${basic_dict} =     Create Dictionary        key2=value2
    # test
    Run Keyword And Ignore Error    Dictionary Should Not Contain Value     ${compound_dict}        ${basic_dict}
    Dictionary Should Not Contain Value     ${compound_dict}    X   # passes

Use "Get Dictionary Items" (Into A List)
    [Documentation]     Get Dictionary Items 	dictionary, sort_keys=True
    ...                 Returns items of the given dictionary as a list.
    ...                 Items are returned as a flat list so that first item is a key, second item is a corresponding value,
    ...                 third item is the second key, and so on.
    &{compound_dict} =  get compound dictionary  # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    Log     ${compound_dict}
    @{items} =      Get Dictionary Items    ${compound_dict}  sort_keys=${True}    # test
    Should Be True     $items == ['deep_dict', {'key2': 'value2'}, 'key1', 'value1']
    @{items} =      Get Dictionary Items    ${compound_dict}  sort_keys=${False}        # test, should the items in original order
    Should Be True     $items == ['key1', 'value1', 'deep_dict', {'key2': 'value2'}]    # yes it does

Use "Get Dictionary Keys" (Into A List)
 	[Documentation]     Get Dictionary Keys 	dictionary, sort_keys=True
 	...                 By default keys are returned in sorted order (assuming they are sortable), but
 	...                 they can be returned in the original order by giving sort_keys a false value
 	...                 https://github.com/robotframework/robotframework/blob/7bda996b95268f4b3451192edc4dedd58543d3f8/src/robot/libraries/Collections.py#L580
    &{compound_dict} =  get compound dictionary  # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    @{items} =          Get Dictionary Keys     ${compound_dict}    sort_keys=${False}   # keys are given in the original order
    Should Be True      $items == ['key1', 'deep_dict']      # yes, in the original order
    @{items} =          Get Dictionary Keys     ${compound_dict}    sort_keys=${True}   # keys are given in sorted order
    Should Be True      ${items} == ['deep_dict', 'key1']

Use "Get Dictionary Values" (Into A List)
    [Documentation]     Get Dictionary Values 	dictionary, sort_keys=True
    ...                 Returns values of the given dictionary as a list.
    ...                 By default keys are sorted and values returned in that order, but this can be changed
    ...                 by giving sort_keys a false value

    &{d3} =             Create Dictionary   b=${2}  c=${3}   a=${1}
    @{sorted} =         Get Dictionary Values   ${d3}  sort_keys=${True}        # @{sorted} = [ 1 | 2 | 3 ]
    @{unsorted} =       Get Dictionary Values   ${d3}  sort_keys=${False}       # @{unsorted} = [ 2 | 3 | 1 ]

Use "Get From Dictionary" (A Value Based On A Given Key)
    [Documentation]     Get From Dictionary 	dictionary, key
    ...                 Returns a value from the given dictionary based on the given key.
    ...                 If the given key cannot be found from the dictionary, this keyword fails.
    [Tags]              failure-expected

    &{d3} =             Create Dictionary   b=${2}  c=${3}   a=${1}
    ${value} =          Get From Dictionary     ${d3}   c       # test
    Should Be Equal     ${value}       ${3}                     # passed

    # test to fail as expected
    ${will_fail} =      Get From Dictionary     ${d3}   keyX

Use "Get From List" (An Item Based On A Given Index)
    [Documentation]     Get From List 	list_, index
    ...                 Index 0 means the first position, 1 the second, and so on. Similarly, -1 is the last position,
    ...                 -2 the second last, and so on. Using an index
    ...                 that does not exist on the list causes an error. The index can be either an integer
    ...                 or a string that can be converted to an integer
    [Tags]              failure-expected

    ${lst} =            get list  # from Resources/Utils.py;    ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${item} =           Get From List   list_=${lst}    index=${3}   # test
    Should Be Equal     ${item}     c                                # passes

    ${item} =           Get From List   list_=${lst}    index=${-3}   # test
    Should Be Equal     ${item}     ${1}                              # passes

    # giving an index, which is out of range, will fail as expected
    ${will_fail} =           Get From List       list_=${lst}        index=${100}

Use "Get Index From List"
    [Documentation]     Get Index From List 	list_, value, start=0, end=None
    ...                 Returns the index of the first occurrence of the value on the list
    ...                 The search can be narrowed to the selected sublist by the start and end indexes
    ...                 having the same semantics as with Get Slice From List keyword.
    ...                 In case the value is not found, -1 is returned.

    ${lst} =            get list  # from Resources/Utils.py;    ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${index} =          Get Index From List     list_=${lst}  value=a  start=${0}   end=None    # test
    Should Be Equal     ${index}     ${0}   # passes
    ${index} =          Get Index From List     list_=${lst}  value=a  start=${index+1}   end=None    # test
    Should Be Equal     ${index}     ${2}   # passes
    ${index} =          Get Index From List     list_=${lst}  value=a  start=${index+1}   end=None    # test
    Should Be Equal     ${index}     ${-1}   # passes

Use "Get Match Count" (From A List)
    [Documentation]     Get Match Count 	list, pattern, case_insensitive=False, whitespace_insensitive=False
    ...                 Returns the count of matches to pattern in list.
    ...                 For more information on pattern, case_insensitive, and whitespace_insensitive, see Should Contain Match.
    [Tags]              not-understood

    ${lst} =    Create List   an item   another item    123456   AN ITEM    ab with whitespace  ABwithoutwhitespace

    ${count} =  Get Match Count     ${lst}  glob=a*  case_insensitive=${False}  whitespace_insensitive=${False}  # test
    Should Be Equal     ${count}    ${3}    # passes

    ${count} =  Get Match Count     ${lst}  regexp=a.*  case_insensitive=${False}  whitespace_insensitive=${False}  # test, the same pattern as above but in regexp
    Should Be Equal     ${count}    ${3}    # passes

    ${count} =  Get Match Count     ${lst}  regexp=\\d{6}  case_insensitive=${False}  whitespace_insensitive=${False}  # test
    Should Be Equal     ${count}    ${1}    # passes

    ${count} =  Get Match Count     ${lst}  glob=a* 	case_insensitive=${True}  whitespace_insensitive=${False}  # test
    Should Be Equal     ${count}    ${5}    # passes

    ${count} =  Get Match Count     ${lst}  glob=ab* 	whitespace_insensitive=${True} 	case_insensitive=${False}   # test
    Should Be Equal     ${count}    ${1}    # passes

    ${count} =  Get Match Count     ${lst}  glob=ab* 	whitespace_insensitive=${True} 	case_insensitive=${True}   # test
    Should Be Equal     ${count}    ${2}    # passes

Use "Get Matches" (To A Pattern In List)
    [Documentation]     Get Matches 	list, pattern, case_insensitive=False, whitespace_insensitive=False
    ...                 Returns a list of matches to pattern in list
    ...                 For more information on pattern, case_insensitive, and whitespace_insensitive, see Should Contain Match.

    ${lst} =    Create List   an item   another item    123456   AN ITEM    ab with whitespace  ABwithoutwhitespace

    ${matches} =    Get Matches    ${lst}    glob=ab*    whitespace_insensitive=${True} 	case_insensitive=${True}   # test
    Should Be True  $matches == ['ab with whitespace', 'ABwithoutwhitespace']   # passes

    ${matches} =    Get Matches    ${lst}    glob=ab*    whitespace_insensitive=${True} 	case_insensitive=${False}   # test
    Should Be True     $matches == ['ab with whitespace']   # passes

    ${matches} =    Get Matches    ${lst}  glob=a* 	case_insensitive=${True}  whitespace_insensitive=${False}   # test
    Should Be True     $matches == ['an item', 'another item', 'AN ITEM', 'ab with whitespace', 'ABwithoutwhitespace']      # passes

    # a test that gets no matches ==> an empty list is expected
    ${matches} =    Get Matches    ${lst}  glob=notFound* 	case_insensitive=${True}  whitespace_insensitive=${True}   # test
    Should Be True     $matches == []       # passes

Use "Get Slice From List"
    [Documentation]     https://github.com/robotframework/robotframework/blob/7bda996b95268f4b3451192edc4dedd58543d3f8/src/robot/libraries/Collections.py#L197
    ...                 Get Slice From List 	list_, start=0, end=None
    ...                 Returns a slice of the given list between start (inclusive) and end (exclusive) indexes.
    ...                 If both start and end are given, a sublist containing values from start to end is returned.
    ...                 This is the same as list[start:end] in Python.
    ...                 To get all items from the beginning, use 0 as the start value, and to get all items
    ...                 until and including the end, use None (default) as the end value.
    ${lst} =            get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]  # length 10

    ${sliced} =         Get Slice From List     list_=${lst}    start=0   end=None      # test
    Should Be Equal     ${lst}      ${sliced}   # passes

    ${sliced} =         Get Slice From List     list_=${lst}    start=${1}   end=${4}      # test
    Should Be True     $sliced == ['b', 'a', 'c']

    # Using positive start or positive end not found on the list is the same as using the largest available index
    ${sliced} =         Get Slice From List     list_=${lst}    start=${13}   end=${20}      # test
    Should Be True     $sliced == []    # same as lst[10:10]

    ${sliced} =         Get Slice From List     list_=${lst}    start=${13}   end=${-3}      # test
    Should Be True     $sliced == []    # same as lst[10:-3];  no elements to the right of 10 which ends up at index -3

    # Using negative start or negative end not found on the list is the same as using the smallest available index
    ${sliced} =         Get Slice From List     list_=${lst}    start=${-15}   end=${-13}      # test
    Should Be True     $sliced == []    # same as lst[0:0]

    ${sliced} =         Get Slice From List     list_=${lst}    start=${-15}   end=${3}      # test
    Should Be True     $sliced == ['a', 'b', 'a']    # same as lst[0:3]

Use "Insert Into List"
    [Documentation]     Insert Into List 	list_, index, value
    ...                 Inserts value into list to the position specified with index.
    ...                 Index 0 adds the value into the first position, 1 to the second, and so on.
    ...                 Inserting from right works with negative indices so that -1 is the second last position, -2 third last,
    ...                 and so on
    ${lst} =            get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]

    Insert Into List    list_=${lst}   index=${0}  value=X  # test; X is inserted to the beginning
    Evaluate     $lst==['X', 'a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]

    Insert Into List    list_=${lst}   index=${4}  value=X  # test; X is inserted to the middle
    Evaluate     $lst==['X', 'a', 'b', 'a', 'X', 'c', 1, 0, 3, 1, 2, 1]

    Insert Into List    list_=${lst}   index=${-1}  value=X  # test; X is inserted to the second last position
    Evaluate     $lst==['X', 'a', 'b', 'a', 'X', 'c', 1, 0, 3, 1, 2, 'X', 1]

Use "Keep In Dictionary" (The Given Keys And Remove All Other)
    [Documentation]     Keep In Dictionary 	dictionary, *keys
    ...                 Keeps the given keys in the dictionary and removes all other.
    ...                 If the given key cannot be found from the dictionary, it is ignored.

    &{d} =  get compound dictionary     # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    Keep In Dictionary      ${d}    key1   non-existing-key-ignored     # test
    ${expected_d} =  Create Dictionary      key1=value1
    Dictionaries Should Be Equal        ${d}        ${expected_d}       # passed

Use "List Should Contain Sub List"
    [Documentation]     List Should Contain Sub List 	list1, list2, msg=None, values=True
    ...                 Fails if not all of the elements in list2 are found in list1.
    ...                 The order of values and the number of values are not taken into account.
    [Tags]              failure-expected
    ${lst} =            get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${sub_list_passing} =       Create List     ${3}    c     ${0}      c

    List Should Contain Sub List    list1=${lst}    list2=${sub_list_passing}   # passes

    ${sub_list_failing} =       Create List     ${3}    c     ${0}      x
    Run Keyword And Ignore Error    List Should Contain Sub List    list1=${lst}    list2=${sub_list_failing}   # fails as expected

Use "List Should Contain Value"
    [Documentation]         List Should Contain Value 	list_, value, msg=None
    [Tags]              failure-expected
    ${lst} =            get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    List Should Contain Value   list_=${lst}        value=c
    Run Keyword And Ignore Error        List Should Contain Value   list_=${lst}        value=x

Use "List Should Not Contain Duplicates"
    [Documentation]     List Should Not Contain Duplicates 	list_, msg=None
    ...                 Fails if any element in the list is found from it more than once
    ...                 This keyword works with all iterables that can be converted to a list.
    ...                 The original iterable is never altered.
    # using a list
    ${lst_with_duplicates} =    get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${lst_with_uniques} =       Create List     a   b   c
    Run Keyword And Ignore Error        List Should Not Contain Duplicates   ${lst_with_duplicates}
    List Should Not Contain Duplicates      ${lst_with_uniques}

    # with tuples
    ${tuple_with_duplicates} =  get tuple with duplicates   # from Resources/Utils.py; ('a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1)
    ${tuple_with_uniques} =     get tuple with uniques      # from Resources/Utils.py; (1, 2, 3, 4, 5,)
    Run Keyword And Ignore Error    List Should Not Contain Duplicates      ${tuple_with_duplicates}
    List Should Not Contain Duplicates      ${tuple_with_uniques}

Use "List Should Not Contain Value"
    [Documentation]     List Should Not Contain Value 	list_, value, msg=None
    [Tags]              failure-expected
    ${lst} =    get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    Run Keyword And Ignore Error    List Should Not Contain Value       ${lst}   c
    List Should Not Contain Value   ${lst}    x

Use "Lists Should Be Equal"
 	[Documentation]      http://robotframework.org/robotframework/latest/libraries/Collections.html#Lists%20Should%20Be%20Equal
 	...                  Lists Should Be Equal 	list1, list2, msg=None, values=True, names=None
 	...                  The types of the lists do not need to be the same.
 	...                  For example, Python tuple and list with same content are considered equal.
 	[Tags]               failure-expected

    ${lst} =    get basic list               # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${t} =    get tuple with duplicates      # from Resources/Utils.py; ('a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1)
    Lists Should Be Equal  ${t}     ${lst}   # Python tuple and list with same content are considered equal.

    @{people1} =        Create List     Paul     Brown   paul@brown.com
    @{people2} =        Create List     David    Brown   david@brown.com
    &{names} =          Create Dictionary  ${0}=name    ${1}=surname    ${2}=email
    Run Keyword And Ignore Error    Lists Should Be Equal   ${people1}   ${people2}     names=${names}

Use "Log Dictionary"
    &{d} =  get compound dictionary     # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    Log Dictionary  ${d}    level=TRACE     # smallest amount of logging
    Log Dictionary  ${d}    level=DEBUG
    Log Dictionary  ${d}    level=INFO
    Log Dictionary  ${d}    level=WARN      # highest amount of logging

Use "Log List"
    ${lst} =            get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    Log List    ${lst}      level=TRACE     # smallest amount of logging
    Log List    ${lst}      level=DEBUG
    Log List    ${lst}      level=INFO
    Log List    ${lst}      level=WARN      # highest amount of logging

Use "Pop From Dictionary"
    [Documentation]     Pop From Dictionary 	dictionary, key, default=
    ...                 Pops the given key from the dictionary and returns its value.
    ...                 By default the keyword fails if the given key cannot be found from the dictionary.
    ...                 If optional default value is given, it will be returned instead of failing.
    &{d} =  get compound dictionary     # from Resources/Utils.py; {'key1': 'value1', 'deep_dict': {'key2': 'value2'}}
    ${sub_dict} =   Pop From Dictionary     ${d}    key=deep_dict       # ${sub_dict} = {'key2': 'value2'}
    ${minus_one} =   Pop From Dictionary     ${d}    key=X      default=${-1}  # ${minus_one} = -1

Use "Remove Duplicates" (From A List)
    [Documentation]     Remove Duplicates 	list_
    ...                 Returns a NEW list without duplicates based on the given list

    ${lst_with_duplicates} =    get basic list      # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${lst_with_uniques} =   Remove Duplicates   list_=${lst_with_duplicates}  #['a', 'b', 'c', 1, 0, 3, 2]

Use "Remove From Dictionary"
    &{d3} =             Create Dictionary   b=${2}  c=${3}   a=${1}
    &{d3_expected} =    Create Dictionary   c=${3}   a=${1}
    # test
    Remove From Dictionary  ${d3}   b   x  y    # If the given key cannot be found from the dictionary, it is ignored
    Should Be Equal   ${d3}     ${d3_expected}  # passed

Use "Remove From List"
    [Documentation]     Remove From List 	list_, index
    ...                 Removes and returns the value specified with an index from list (modified).
    ...                 Index 0 means the first position, 1 the second and so on.
    ...                 Similarly, -1 is the last position, -2 the second last, and so on.
    ...                 Using an index that does not exist on the list causes an error.
    [Tags]          failure-expected
    @{lst} =      get basic list               # from Resources/Utils.py; ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${value} =    Remove From List  list_=${lst}    index=${2}  # lst:    ['a', 'b', 'c', 1, 0, 3, 1, 2, 1]
    Should Be Equal     ${value}    a
    ${value} =    Remove From List  list_=${lst}    index=${-1}  # lst:    ['a', 'b', 'c', 1, 0, 3, 1, 2]
    Should Be Equal     ${value}    ${1}
    ${fails} =    Remove From List  list_=${lst}    index=${100}  # Using an index that does not exist on the list causes an error.

Use "Reverse List"
    [Documentation]     Reverse List 	list_
    ...                 Reverses the given list in place. Note that the given list is changed and nothing is returned.
    ${l2} =     Create List     a   b
    Reverse List    ${l2}
    Evaluate    $l2==['b', 'a']

Use Set List Value"
    [Documentation]     Set List Value 	list_, index, value
    ...                 Sets the value of list specified by index to the given value
    ...                 Index 0 means the first position, 1 the second and so on.
    ...                 Similarly, -1 is the last position, -2 second last, and so on.
    ...                 Note that the original value in the provided index is replaced by value
    ...                 Using an index that does not exist on the list causes an error
    ${l5} =     Create List     a   b   c   d   e
    Set List Value      list_=${l5}     index=${2}     value=X
    Evaluate    $l5==['a', 'b', 'X', 'd', 'e']

    Set List Value      list_=${l5}     index=${-1}     value=X
    Evaluate    $l5==['a', 'b', 'X', 'd', 'X']

Use "Set To Dictionary"
    [Documentation]     https://github.com/robotframework/robotframework/blob/7bda996b95268f4b3451192edc4dedd58543d3f8/src/robot/libraries/Collections.py#L482
    ...                 Set To Dictionary 	dictionary, *key_value_pairs, **items
    ...                 Adds first the given key_value_pairs and afterwards items to the dictionary.
    ...                 If given keys already exist in the dictionary, their values are updated.
    ...                 note that if key_value_pairs and items have the same keys, items keys'
    ...                 values will be written into the dictionary
    ${d} =      get basic dictionary    # From Resources/Utils.py; {'key1': 'value1', 'key2': 'value2'}
    @{kwp} =    Create List     key2    overwritten2    key3    ${3}    key4    ${4}
    &{items}=   Create Dictionary   key4  overwritten4
    Set To Dictionary   ${d}  @{kwp}  &{items}    # test; d is updated in place
    Evaluate    $d=={'key1': 'value1', 'key2':'overwritten2', 'key3':3, 'key4':'overwritten4'}  # passed


Use "(List) Should Contain Match (To Given Pattern)"
    [Documentation]     Should Contain Match 	list, pattern, msg=None, case_insensitive=False, whitespace_insensitive=False
    ...                 Fails if pattern is not found in list.
    ...                 Glob pattern:
    ...                 By default, pattern matching is similar to matching files in a shell and
    ...                 is case-sensitive and whitespace-sensitive. In the pattern syntax, * matches to anything and
    ...                 ? matches to any single character. You can also prepend glob= to your pattern to explicitly use
    ...                 this pattern matching behavior.
    ...                 RegExp pattern:
    ...                 If you prepend regexp= to your pattern, your pattern will be used according to the Python
    ...                 re module regular expression syntax. Important note: Backslashes are an escape character,
    ...                 and must be escaped with another backslash (e.g. regexp=\\d{6} to search for \d{6}).
    ...                 See BuiltIn.Should Match Regexp for more details.
    [Tags]              not-understood

    ${lst} =    Create List   an item   another item    123456   AN ITEM    ab with whitespace  ABwithoutwhitespace
    Should Contain Match 	${lst} 	glob=a* 			# Match strings beginning with 'a'.
    Should Contain Match 	${lst} 	regexp=a.* 			# Same as the above but with regexp.
    Should Contain Match 	${lst} 	regexp=\\d{6} 			# Match strings containing six digits.
    Should Contain Match 	${lst} 	glob=a* 	case_insensitive=${True} 		# Match strings beginning with 'a' or 'A'.
    Should Contain Match 	${lst} 	glob=ab* 	whitespace_insensitive=${True} 		# Match strings beginning with 'ab' with possible whitespace ignored.
    Should Contain Match 	${lst} 	glob=ab* 	whitespace_insensitive=${True} 	case_insensitive=${True} 	# Same as the above but also ignore case.

Use "(List) Should Not Contain Match (To Given Pattern)"
    [Documentation]     Exact opposite of Should Contain Match keyword as the previous test above
    ${lst} =    Create List   ${1}  ${2}   ${3}
    Should Not Contain Match 	${lst} 	glob=a* 			# Match strings beginning with 'a'.
    Should Not Contain Match 	${lst} 	regexp=a.* 			# Same as the above but with regexp.
    Should Not Contain Match 	${lst} 	regexp=\\d{6} 			# Match strings containing six digits.
    Should Not Contain Match 	${lst} 	glob=a* 	case_insensitive=${True} 		# Match strings beginning with 'a' or 'A'.
    Should Not Contain Match 	${lst} 	glob=ab* 	whitespace_insensitive=${True} 		# Match strings beginning with 'ab' with possible whitespace ignored.
    Should Not Contain Match 	${lst} 	glob=ab* 	whitespace_insensitive=${True} 	case_insensitive=${True} 	# Same as the above but also ignore case.


Use "Sort List"
    [Documentation]     Sort List 	list_
    ...                 Sorts the given list in place.
    ...                 Sorting fails if items in the list are not comparable with each others.
    ...                 On Python 3 comparing, for example, strings with numbers is not possible.
    [Tags]              failure-expected

    # with a list containing numbers
    ${lst} =     Create List  ${3}  ${1}  ${2}  # unsorted originally
    Should Be True    $lst == [3, 1, 2]
    Should Be True   $lst != [1, 2, 3]
    Sort List   ${lst}  # test; in place
    Should Be True    $lst == [1, 2, 3]

    # with a list containing strings
    ${lst} =     Create List  c  a  b           # unsorted originally
    Should Be True    $lst == ['c', 'a', 'b']
    Should Be True   $lst != ['a', 'b', 'c']
    Sort List   ${lst}  # test; in place
    Should Be True   $lst == ['a', 'b', 'c']

    # with a list containing strings and numbers
    ${lst} =     Create List  c  a  b   ${3}  ${1}  ${2}
    Run Keyword And Ignore Error    Sort List   ${lst}  # test; expected to fail