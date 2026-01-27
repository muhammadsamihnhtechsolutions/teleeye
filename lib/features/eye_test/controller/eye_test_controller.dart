import 'package:get/get.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';

class EyeTestController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();

  Future<String> _resolvePatientId() async {
    try {
      final profileCtrl = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

      if (profileCtrl.profileData.value.profile == null) {
        await profileCtrl.getProfileData();
      }

      return (profileCtrl.profileData.value.profile?.sId ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  String _existingVisualLeft() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.visualAcuity
                  ?.left
                  ?.os ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _existingVisualRight() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.visualAcuity
                  ?.right
                  ?.od ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _existingNearLeft() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.nearVision
                  ?.left
                  ?.os ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _existingNearRight() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.nearVision
                  ?.right
                  ?.od ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _existingColorLeft() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.colorVision
                  ?.left ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _existingColorRight() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.colorVision
                  ?.right ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _existingAmdLeft() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.amdVision
                  ?.left ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  String _existingAmdRight() {
    try {
      if (!Get.isRegistered<MoreController>()) return '';
      return (Get.find<MoreController>()
                  .appTestResultResponse
                  .value
                  ?.appTestData
                  ?.amdVision
                  ?.right ??
              '')
          .toString()
          .trim();
    } catch (_) {
      return '';
    }
  }

  Future<void> _refreshAppTestResults() async {
    if (!Get.isRegistered<MoreController>()) {
      return;
    }
    try {
      await Get.find<MoreController>().fetchAppTestResults();
    } catch (_) {
      // ignore
    }
  }

  // Observable variables
  var isLeftEye = true.obs;
  var leftEyeScore = '0/0'.obs;
  var rightEyeScore = '0/0'.obs;

  final nearVisionLeftCounter = 0.obs;
  final nearVisionRightCounter = 0.obs;

  final colorVisionLeftCorrect = 0.obs;
  final colorVisionRightCorrect = 0.obs;

  final amdLeftCounter = 0.obs;
  final amdRightCounter = 0.obs;

  // Update current eye being tested
  void updateCurrentEye(bool isLeft) {
    isLeftEye.value = isLeft;
  }

  // Update score for current eye
  void updateScore(String score) {
    if (isLeftEye.value) {
      leftEyeScore.value = score;
    } else {
      rightEyeScore.value = score;
    }

    print("Current left eye score: ${leftEyeScore.value}");
    print("Current right eye score: ${rightEyeScore.value}");
  }

  // Reset scores
  void resetScore() {
    isLeftEye.value = true;
    leftEyeScore.value = '0/0';
    rightEyeScore.value = '0/0';
  }

  void resetNearVision() {
    nearVisionLeftCounter.value = 0;
    nearVisionRightCounter.value = 0;
  }

  void resetColorVision() {
    colorVisionLeftCorrect.value = 0;
    colorVisionRightCorrect.value = 0;
  }

  void resetAmd() {
    amdLeftCounter.value = 0;
    amdRightCounter.value = 0;
  }

  void incrementNearVisionLeft() {
    nearVisionLeftCounter.value = nearVisionLeftCounter.value + 10;
  }

  void incrementNearVisionRight() {
    nearVisionRightCounter.value = nearVisionRightCounter.value + 10;
  }

  void incrementColorVisionLeft() {
    colorVisionLeftCorrect.value = colorVisionLeftCorrect.value + 1;
  }

  void incrementColorVisionRight() {
    colorVisionRightCorrect.value = colorVisionRightCorrect.value + 1;
  }

  void incrementAmdLeft() {
    amdLeftCounter.value = amdLeftCounter.value + 5;
  }

  void incrementAmdRight() {
    amdRightCounter.value = amdRightCounter.value + 5;
  }

  // Get current eye score
  String getCurrentEyeScore() {
    return isLeftEye.value ? leftEyeScore.value : rightEyeScore.value;
  }

  // Check if both eyes have scores
  bool areBothEyesTested() {
    return leftEyeScore.value != '0/0' && rightEyeScore.value != '0/0';
  }

  // Get formatted result for API
  Map<String, dynamic> getTestResults() {
    return {
      'leftEyeScore': leftEyeScore.value,
      'rightEyeScore': rightEyeScore.value,
    };
  }

  Future<void> submitVisualAcuityResults() async {
    try {
      final profileId = await _resolvePatientId();
      if (profileId.isEmpty) return;

      await _apiRepo.updateVisualAcuityTestResults(
        patientId: profileId,
        leftEyeScore: leftEyeScore.value,
        rightEyeScore: rightEyeScore.value,
      );

      await _refreshAppTestResults();
    } catch (_) {
      // ignore
    }
  }

  Future<void> submitNearVisionResults() async {
    try {
      final profileId = await _resolvePatientId();
      if (profileId.isEmpty) return;

      final safeVisualLeft = (leftEyeScore.value.trim() != '0/0')
          ? leftEyeScore.value.trim()
          : ((_existingVisualLeft().isNotEmpty) ? _existingVisualLeft() : '--');
      final safeVisualRight = (rightEyeScore.value.trim() != '0/0')
          ? rightEyeScore.value.trim()
          : ((_existingVisualRight().isNotEmpty)
                ? _existingVisualRight()
                : '--');

      await _apiRepo.updateNearVisionTestResults(
        patientId: profileId,
        leftEyeCounter: nearVisionLeftCounter.value,
        rightEyeCounter: nearVisionRightCounter.value,
        leftVisualAcuityScore: safeVisualLeft,
        rightVisualAcuityScore: safeVisualRight,
      );

      await _refreshAppTestResults();
    } catch (_) {
      // ignore
    }
  }

  Future<void> submitColorVisionResults() async {
    try {
      final profileId = await _resolvePatientId();
      if (profileId.isEmpty) return;

      final leftResult = colorVisionLeftCorrect.value >= 5
          ? 'Normal'
          : 'Abnormal';
      final rightResult = colorVisionRightCorrect.value >= 5
          ? 'Normal'
          : 'Abnormal';

      final safeVisualLeft = (leftEyeScore.value.trim() != '0/0')
          ? leftEyeScore.value.trim()
          : ((_existingVisualLeft().isNotEmpty) ? _existingVisualLeft() : '--');
      final safeVisualRight = (rightEyeScore.value.trim() != '0/0')
          ? rightEyeScore.value.trim()
          : ((_existingVisualRight().isNotEmpty)
                ? _existingVisualRight()
                : '--');

      final safeNearLeft = (nearVisionLeftCounter.value > 0)
          ? '${nearVisionLeftCounter.value}/23'
          : ((_existingNearLeft().isNotEmpty) ? _existingNearLeft() : '--');
      final safeNearRight = (nearVisionRightCounter.value > 0)
          ? '${nearVisionRightCounter.value}/23'
          : ((_existingNearRight().isNotEmpty) ? _existingNearRight() : '--');

      await _apiRepo.updateColorVisionTestResults(
        patientId: profileId,
        leftResult: leftResult,
        rightResult: rightResult,
        leftVisualAcuityScore: safeVisualLeft,
        rightVisualAcuityScore: safeVisualRight,
        leftNearVisionResult: safeNearLeft,
        rightNearVisionResult: safeNearRight,
      );

      await _refreshAppTestResults();
    } catch (_) {
      // ignore
    }
  }

  Future<void> submitAmdResults() async {
    try {
      final profileId = await _resolvePatientId();
      if (profileId.isEmpty) return;

      final leftResult = amdLeftCounter.value >= 5 ? 'Normal' : 'Abnormal';
      final rightResult = amdRightCounter.value >= 5 ? 'Normal' : 'Abnormal';

      final safeVisualLeft = (leftEyeScore.value.trim() != '0/0')
          ? leftEyeScore.value.trim()
          : ((_existingVisualLeft().isNotEmpty) ? _existingVisualLeft() : '--');
      final safeVisualRight = (rightEyeScore.value.trim() != '0/0')
          ? rightEyeScore.value.trim()
          : ((_existingVisualRight().isNotEmpty)
                ? _existingVisualRight()
                : '--');

      final safeNearLeft = (nearVisionLeftCounter.value > 0)
          ? '${nearVisionLeftCounter.value}/23'
          : ((_existingNearLeft().isNotEmpty) ? _existingNearLeft() : '--');
      final safeNearRight = (nearVisionRightCounter.value > 0)
          ? '${nearVisionRightCounter.value}/23'
          : ((_existingNearRight().isNotEmpty) ? _existingNearRight() : '--');

      await _apiRepo.updateAmdTestResults(
        patientId: profileId,
        leftResult: leftResult,
        rightResult: rightResult,
        leftVisualAcuityScore: safeVisualLeft,
        rightVisualAcuityScore: safeVisualRight,
        leftNearVisionResult: safeNearLeft,
        rightNearVisionResult: safeNearRight,
        colorVisionLeft: colorVisionLeftCorrect.value >= 5
            ? 'Normal'
            : 'Abnormal',
        colorVisionRight: colorVisionRightCorrect.value >= 5
            ? 'Normal'
            : 'Abnormal',
      );

      await _refreshAppTestResults();
    } catch (_) {
      // ignore
    }
  }

  Map<String, dynamic>? buildResultsPayloadForSend() {
    String resolveVisual(String current, String existing) {
      final safeCurrent = current.trim();
      if (safeCurrent.isNotEmpty && safeCurrent != '0/0') return safeCurrent;
      if (existing.isNotEmpty) return existing;
      return '--';
    }

    String resolveNear(int counter, String existing) {
      if (counter > 0) return '$counter/23';
      if (existing.isNotEmpty) return existing;
      return '--';
    }

    String resolveBinaryResult(int counter, String existing) {
      if (counter > 0) return counter >= 5 ? 'Normal' : 'Abnormal';
      if (existing.isNotEmpty) return existing;
      return '--';
    }

    final visualLeft = resolveVisual(leftEyeScore.value, _existingVisualLeft());
    final visualRight =
        resolveVisual(rightEyeScore.value, _existingVisualRight());
    final nearLeft =
        resolveNear(nearVisionLeftCounter.value, _existingNearLeft());
    final nearRight =
        resolveNear(nearVisionRightCounter.value, _existingNearRight());

    final colorLeft =
        resolveBinaryResult(colorVisionLeftCorrect.value, _existingColorLeft());
    final colorRight = resolveBinaryResult(
      colorVisionRightCorrect.value,
      _existingColorRight(),
    );

    final amdLeft = resolveBinaryResult(amdLeftCounter.value, _existingAmdLeft());
    final amdRight =
        resolveBinaryResult(amdRightCounter.value, _existingAmdRight());

    final values = [
      visualLeft,
      visualRight,
      nearLeft,
      nearRight,
      colorLeft,
      colorRight,
      amdLeft,
      amdRight,
    ];
    final hasData = values.any(
      (v) => v.isNotEmpty && v != '--' && v != '0/0',
    );
    if (!hasData) return null;

    return {
      'visualAcuity': {
        'left': {'os': visualLeft},
        'right': {'od': visualRight},
      },
      'nearVision': {
        'left': {'os': nearLeft},
        'right': {'od': nearRight},
      },
      'colorVision': {'left': colorLeft, 'right': colorRight},
      'amdVision': {'left': amdLeft, 'right': amdRight},
    };
  }
}
