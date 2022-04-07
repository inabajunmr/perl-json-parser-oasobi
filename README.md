# perl-json-parser-oasobi

## Sample

```perl
my %result = %{Acme::Inabajun::Json::Parser->parse('
{
    "key1":"value1",
    "key2":"value2",
    "key3":{
        "ckey1":"cvalue1",
            "ckey2":"cvalue2"
            },
    "key4":[1,2,3]
    }')};
is($result{key1}, 'value1', 'parent key1 is "value1"');
is($result{key2}, 'value2', 'parent key2 is "value2"');
is($result{key3}->{ckey1}, 'cvalue1', 'key3->ckey1 is "cvalue1"');
is($result{key3}->{ckey2}, 'cvalue2', 'key3->ckey2 is "cvalue2"');
is($result{key4}->[0], 1, 'parent key4[0] is value 1');
is($result{key4}->[1], 2, 'parent key4[1] is value 2');
is($result{key4}->[2], 3, 'parent key4[2] is value 3');
```

## Development

### test

```
./Build test
```