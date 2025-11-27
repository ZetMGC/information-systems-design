enum SortField {last_name, first_name, id, experience_years}

class QuerySort {
  final SortField field;
  final bool asc;
  const QuerySort(this.field, {this.asc = true});

  String toOrderBySql() {
    final col = switch (field) {
      SortField.last_name => 'lower(last_name)',
      SortField.first_name => 'lower(first_name)',
      SortField.id => 'id',
      SortField.experience_years => 'experience_years'
    };

    return '$col ${asc ? 'ASC' : 'DESC'}, id ASC';
  }
}

class QueryFilter {
  final String where;
  final Map<String, dynamic> params;
  const QueryFilter(this.where, [this.params = const {}]);

  static const none = QueryFilter('');
}