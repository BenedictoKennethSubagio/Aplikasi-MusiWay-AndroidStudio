import 'package:firebase_auth/firebase_auth.dart';
import 'package:test2/models/direction_detailinfo.dart';

import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;
String userDropOffAddress = "";
DirectionDetailinfo? tripDirectionDetailsInfo;