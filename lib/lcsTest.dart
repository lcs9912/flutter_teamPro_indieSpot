import 'dart:io';

// 에뮬레이터에서 확인한 이미지 파일의 경로와 이름
String emulatorImagePath = '/path/to/emulator/image.png';

// 에뮬레이터에서 확인한 이미지 파일의 이름
String imageName = 'image.png';

// 이미지 파일을 불러오는 함수
Future<Object> loadImage() async {
  try {
    File imageFile = File(emulatorImagePath);
    // 이미지 파일을 읽고 반환
    return imageFile;
  } catch (e) {
    print('이미지를 불러오는 중 에러가 발생했습니다: $e');
    return "안됨";
  }
}

void main() async {
  // 이미지를 불러오고 출력
  File? image = (await loadImage()) as File?;
  if (image != null) {
    print('이미지 파일 이름: $imageName');
    // 여기에서 이미지 파일을 사용하거나 표시할 수 있습니다.
  } else {
    print('이미지를 불러오지 못했습니다.');
  }
}
