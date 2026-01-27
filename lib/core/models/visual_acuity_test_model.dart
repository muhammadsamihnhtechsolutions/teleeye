// ignore_for_file: public_member_api_docs, sort_constructors_first
class VisualAcuityTestModel {
  String myRange;
  String averageHumansRange;
  int numberOfturns;
  String title;
  String message;
  double sizeInMM;
  VisualAcuityTestModel({
    required this.myRange,
    required this.averageHumansRange,
    required this.numberOfturns,
    required this.title,
    required this.sizeInMM,
    required this.message,
  });
}

List<VisualAcuityTestModel> visualAcuityEyeTestList = [
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "200",
    numberOfturns: 0,
    sizeInMM: 12,
    title: "Severe Vision Loss",
    message: "The object you can see from 20 feet distance , a normal human eye can see it from 200 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "120",
    numberOfturns: 3,
    sizeInMM: 9,
    title: "Moderate Vision Loss",
    message: "The object you can see from 20 feet distance , a normal human eye can see it from 120 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "80",
    numberOfturns: 2,
    sizeInMM: 5,
    title: "Moderate Vision Loss",
    message: "The object you can see from 20 feet distance , a normal human eye can see it from 80 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "60",
    numberOfturns: 1,
    title: "Moderate Vision Loss",
    sizeInMM: 4,
    message: "The object you can see from 20 feet distance , a normal human eye can see it from 60 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "40",
    numberOfturns: 3,
    sizeInMM: 3,
    title: "Mild Vision Loss",
    message: "The object you can see from 20 feet distance , a normal human eye can see it from 40 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "30",
    numberOfturns: 0,
    sizeInMM: 2.5,
    title: "Mild Vision Loss",
    message: "The object you can see from 20 feet distance , a normal human eye can see it from 30 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "20",
    numberOfturns: 1,
    sizeInMM: 2,
    title: "Perfect Vision",
    message: "The object you can see from 20 feet distance , a normal human eye can see it from 20 feet distance",
  ),
];
