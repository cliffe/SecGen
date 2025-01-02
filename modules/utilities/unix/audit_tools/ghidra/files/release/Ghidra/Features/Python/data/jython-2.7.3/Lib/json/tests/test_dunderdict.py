from cStringIO import StringIO
from json.tests import PyTest, CTest


class WrapDict(object):

    def __init__(self, d):
        # Force a copy of the items in d, otherwise __dict__ will be a
        # PyDictionary, instead of the desired PyStringMap for this
        # testing
        self.__dict__.update(d)


class TestDunderDictDump(object):

    def use_dunderdict(self, d):
        return WrapDict(d).__dict__

    def test_dump(self):
        sio = StringIO()
        self.json.dump(self.use_dunderdict({}), sio)
        self.assertEqual(sio.getvalue(), '{}')

    def test_dumps(self):
        self.assertEqual(self.dumps(self.use_dunderdict({})), '{}')

    def test_encode_truefalse(self):
        self.assertEqual(self.dumps(
            self.use_dunderdict({True: False, False: True}), sort_keys=True),
            '{"false": true, "true": false}')
        self.assertEqual(self.dumps(
            self.use_dunderdict({2: 3.0, 4.0: 5L, False: 1, 6L: True}), sort_keys=True),
            '{"false": 1, "2": 3.0, "4.0": 5, "6": true}')


class TestPyDump(TestDunderDictDump, PyTest): pass
class TestCDump(TestDunderDictDump, CTest): pass
