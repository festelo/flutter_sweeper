import 'services/field_manager.dart';

const defaultFieldSize = FieldSize(10, 10);
const defaultBombs = 20;

final bombsOptions = {
  FieldSize(5, 5): [5, 10],
  FieldSize(10, 10): [10, 20, 30],
  FieldSize(15, 15): [20, 30, 40],
};

const fieldSizes = [FieldSize(5, 5), FieldSize(10, 10), FieldSize(15, 15)];
