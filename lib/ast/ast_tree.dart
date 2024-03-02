class AstTree {
  AstTree(this.type, [this.options = const {}, this.nodes = const []]);

  final List<AstTree> nodes;
  final String type;
  final Map<String, String> options;

  Map<String, dynamic> toJson() {
    return {
      'label':
          '$type(${options.entries.map((e) => '${e.key}: ${e.value}').join(', ')})',
      'nodes': nodes.map((e) => e.toJson()).toList(),
    };
  }
}
