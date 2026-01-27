import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';

class EyeListDummyListModel {
  late String title;
  late String iconName;
  late String shortDetails;

  EyeListDummyListModel({
    required this.title,
    required this.iconName,
    required this.shortDetails,
  });
}

class EyeListDummyListModelHandler {
  EyeListDummyListModelHandler._internal();
  static final EyeListDummyListModelHandler _eyeListDummyListModelHandler =
      EyeListDummyListModelHandler._internal();
  factory EyeListDummyListModelHandler() => _eyeListDummyListModelHandler;

  List<EyeListDummyListModel> eyeListDummyListModelList = [
    EyeListDummyListModel(
      title: 'Visual Acuity',
      iconName: AppAssets.visual_acuity,
      shortDetails:
          'The visual acuity test checks how well you see the details of a letter from a specific distance',
    ),
    EyeListDummyListModel(
      title: 'Near Vision',
      iconName: AppAssets.near_vision,
      shortDetails:
          'The near vision test of your ability to see clearly at close range',
    ),
    EyeListDummyListModel(
      title: 'Color Vision',
      iconName: AppAssets.color_vision,
      shortDetails:
          'The color vision test measure the level and type of your color blindness',
    ),
    EyeListDummyListModel(
      title: 'AMD',
      iconName: AppAssets.amd,
      shortDetails:
          'The Amsler grid test check for problem spots in your field of vision (if there are any)',
    ),
  ];
}
