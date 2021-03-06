import 'dart:io';
import 'package:compiled_mustache/compiled_mustache.dart' show compile, CompiledTemplate;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  var specs = new Directory('test/spec/specs').listSync();
  for (FileSystemEntity file in specs) {
    if (file is File && path.extension(file.path) == ".yml") {
      String name = path.basenameWithoutExtension(file.path);
      
      // Lambdas are not yet implemented, skip them
      if (name != '~lambdas') {
        YamlNode spec = loadYaml((file as File).readAsStringSync());
        runSpec(name, spec);
      }
    }
  }
}

void runSpec(String name, YamlNode spec) {
  group(name, () {
    YamlNode tests = spec['tests'];
    
    for (YamlNode test in tests) {
      runTest(test);
    }
    
    // runTest(tests[2]);
  });
}

void runTest(YamlNode t) {
  test(t['name'], () {
    CompiledTemplate ct = compile(t['template']);
    String r = ct.render(t['data'].value, t['partials']?.value);
    expect(r, equals(t['expected']));
  });
}