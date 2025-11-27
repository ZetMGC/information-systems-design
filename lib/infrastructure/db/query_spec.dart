enum SortField { lastName, firstName, id, experienceYears }

class QuerySort {
  final SortField field;
  final bool asc;
  const QuerySort(this.field, {this.asc = true});

  String toOrderBySql() {
    final col = switch (field) {
      SortField.lastName => 'lower(last_name)',
      SortField.firstName => 'lower(first_name)',
      SortField.id => 'id',
      SortField.experienceYears => 'experience_years'
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
