class ExpertFilterModel {
  String heading;

  List<ExpertFilterValues> filterValues;

  ExpertFilterModel({required this.heading, required this.filterValues});

  //copy with
  ExpertFilterModel copyWith({
    String? heading,
    List<ExpertFilterValues>? filterValues,
  }) {
    return ExpertFilterModel(
      heading: heading ?? this.heading,
      filterValues:
          (filterValues ?? this.filterValues).map((e) => e.copyWith()).toList(),
    );
  }
}

class ExpertFilterValues {
  String value;
  String count;
  bool isSelected;

  ExpertFilterValues(
      {required this.value, required this.isSelected, required this.count});

  //copy with
  ExpertFilterValues copyWith({
    String? value,
    String? count,
    bool? isSelected,
  }) {
    return ExpertFilterValues(
      value: value ?? this.value,
      count: count ?? this.count,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
