#!/usr/bin/env python3
'''
This software was created by United States Government employees at 
The Center for Cybersecurity and Cyber Operations (C3O) 
at the Naval Postgraduate School NPS.  Please note that within the 
United States, copyright protection is not available for any works 
created  by United States Government employees, pursuant to Title 17 
United States Code Section 105.   This software is in the public 
domain and is not subject to copyright. 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
'''

'''
   Evaluate a boolean expression given a dictionary of values.
       evaluate_boolean_expression(s, the_dict):
       Where: s is the expression (e.g., "goal1 and (goal2 or goal3)"
              the_dict is a dictionary of boolean values, e.g., the_dict['goal1'] = True.
       See test cases in __main__
'''
import re

str_to_token = {'True':True,
                'False':False,
                'and':lambda left, right: left and right,
                'or':lambda left, right: left or right,
                'and_not':lambda left, right: left and (not right),
                'or_not':lambda left, right: left or (not right),
                'not':'not',
                '(':'(',
                ')':')'}

empty_res = True


def create_token_lst(s, str_to_token=str_to_token):
    """create token list:
    'True or False' -> [True, lambda..., False]"""
    s = s.replace('(', ' ( ')
    s = s.replace(')', ' ) ')
    return [str_to_token[it] for it in s.split()]


def find(lst, what, start=0):
    return [i for i,it in enumerate(lst) if it == what and i >= start]


def parens(token_lst):
    """returns:
        (bool)parens_exist, left_paren_pos, right_paren_pos
    """
    left_lst = find(token_lst, '(')

    if not left_lst:
        return False, -1, -1

    left = left_lst[-1]

    # 'left' is the last '(' in the list, so no '(' lies between it and its
    # matching ')': the first ')' after it is the match. Search from left+1,
    # not left+4 -- a group need not have the shape '( A op B )'. '( X )' and
    # '( not X )' are valid and used to raise IndexError here.
    right = find(token_lst, ')', left + 1)[0]

    return True, left, right


def bool_eval(token_lst):
    '''token_lst has format: [left_arg, operator, right_arg]
        operator(left_arg, right_arg) is returned
        but optionally first token is not, which negates the result 
        if more than one operator are provided, we iterate through them'''
    if len(token_lst) == 1:
        ''' a lone value: a single-operand goal, or a reduced '( X )' group '''
        return token_lst[0]
    is_not = None
    if token_lst[0] == 'not':
        #print('is not, will pop!!!!')
        is_not = token_lst.pop(0)
        token_lst[0] = not token_lst[0]
        if len(token_lst) == 1:
            ''' simple case of boolean : not foo '''
            return token_lst[0]
    #print('%s(%s, %s)' % (token_lst[1], token_lst[0], token_lst[2]))
    tmp = token_lst[1](token_lst[0], token_lst[2])
    #print('bool_eval evaluates to %r' % tmp)
    token_lst.pop(0)
    token_lst.pop(0)
    token_lst.pop(0)
    while len(token_lst) > 0: 
        #print('tokens now %s' % str(token_lst))
        tmp = token_lst[0](tmp, token_lst[1])
        token_lst.pop(0)
        token_lst.pop(0)
    return tmp


def formatted_bool_eval(token_lst, empty_res=empty_res):
    """eval a formatted (i.e. of the form 'ToFa(ToF)') string"""
    if not token_lst:
        return empty_res

    #print('formatted_bool_eval len is %d' % len(token_lst))
    #print(str(token_lst))
    if len(token_lst) == 1:
        return token_lst[0]

    has_parens, l_paren, r_paren = parens(token_lst)

    if not has_parens:
        return bool_eval(token_lst)

    token_lst[l_paren:r_paren + 1] = [bool_eval(token_lst[l_paren+1:r_paren])]
    return formatted_bool_eval(token_lst, bool_eval)


def nested_bool_eval(s):
    """The actual 'eval' routine,
    if 's' is empty, 'True' is returned,
    otherwise 's' is evaluated according to parentheses nesting.
    The format assumed:
        [1] 'LEFT OPERATOR RIGHT',
        where LEFT and RIGHT are either:
                True or False or '(' [1] ')' (subexpression in parentheses)
    """
    return formatted_bool_eval(create_token_lst(s))

def evaluate_boolean_expression(s, the_dict, logger, goals):
    left = s.count('(')
    right = s.count(')')
    if left != right:
        print('ERROR unbalanced parens')
        exit(1)
    replacelist = []
    for key, value in the_dict.items():
        if key not in replacelist:
            replacelist.append(key)
    #print('len of replace list is %d' % len(replacelist))
    #print(str(replacelist))
    sorted_replacelist = sorted(replacelist, key=len, reverse=True)
    for item in sorted_replacelist:
        if item in s:
            value = '%r' % the_dict[item]
            #print('s %s item %s value %s' % (s, item, value))
            s = s.replace(item, value)

    # Strip operators, parens and the substituted True/False so that only
    # unknown or not-yet-valued identifiers remain. Match on word boundaries:
    # the previous space-padded token list could not match a value standing
    # alone (a single-operand goal reduces to exactly 'True'), so every such
    # goal fell through to None and silently graded False.
    remains = re.sub(r'\b(?:and_not|AND_NOT|or_not|OR_NOT|not|NOT|and|AND|or|OR|True|False)\b',
                     ' ', s)
    remains = remains.replace('(', ' ').replace(')', ' ')
    #print('goals is %s' % str(goals))
    if len(remains.strip()) > 0:
        got_unknown = False
        for rem in remains.split():
           if rem not in goals: 
               # an identifier that is no known goal or result is a
               # goals.config error -- say so instead of failing silently
               logger.error('***  unknown token <%s> in boolean expression <%s>' % (rem, s))
               got_unknown = True
        if not got_unknown:
            #logger.debug('goal values not set for this timestamp %s' % (remains))
            pass
        return None
    
    return nested_bool_eval(s) 

if __name__ == "__main__":
    ''' Self-test.  Run:  python3 evalBoolean.py   (exit status 0 on success) '''
    import logging
    import sys
    logging.basicConfig(level=logging.ERROR)
    log = logging.getLogger('evalBoolean-test')
    t_dict = {'goal1': True, 'goal2': False, 'goal3': True, 'goal4': True}
    # goal7 is a known goal that has no value in this timestamped set
    goals = list(t_dict.keys()) + ['goal7']

    cases = [
        # multi-operand expressions (pre-existing behaviour, must not change)
        ('goal1 and goal4 and_not goal2',              True),
        ('goal1 and (not goal2 and goal3)',            True),
        ('goal1 and (goal2 or goal3) and goal4',       True),
        ('goal1 or ((goal2 or goal3) and goal4)',      True),
        ('goal1 and_not ((goal2 or goal3) and goal4)', False),
        # single-operand goals: previously returned None (bare form) or raised
        # IndexError (parenthesised form); both must now evaluate.
        ('goal1',                 True),
        ('goal2',                 False),
        ('(goal1)',               True),
        ('(goal2)',               False),
        ('not goal2',             True),
        ('(not goal2)',           True),
        ('(goal1) and (goal3)',   True),
        # a known goal with no value in this timestamped set -> None (unchanged)
        ('goal1 and (goal2 or goal3) or goal7', None),
    ]
    failed = 0
    for expr, want in cases:
        got = evaluate_boolean_expression(expr, t_dict, log, goals)
        if got != want:
            failed += 1
        print('%s  %-45s -> %r (want %r)' % ('ok ' if got == want else 'FAIL', expr, got, want))
    # an identifier that is not a goal at all is a configuration error -> None
    assert evaluate_boolean_expression('goal1 and nosuch', t_dict, log, goals) is None
    print('%d case(s) failed' % failed)
    sys.exit(1 if failed else 0)


