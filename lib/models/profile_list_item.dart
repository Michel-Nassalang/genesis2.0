import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:genesis/models/constants.dart';

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;

  const ProfileListItem({
    Key? key,
    required this.icon,
    required this.text,
    this.hasNavigation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kSpacingUnit.w * 3.5,
      margin: EdgeInsets.symmetric(
        horizontal: kSpacingUnit.w * 5,
      ).copyWith(
        bottom: kSpacingUnit.w * 2,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: kSpacingUnit.w * 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
        color: Colors.grey,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: kSpacingUnit.w * 2.5,
          ),
          SizedBox(width: kSpacingUnit.w * 1.5),
          Text(
            text,
            style: kTitleTextStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (hasNavigation)
            Icon(
              LineAwesomeIcons.angle_right,
              size: kSpacingUnit.w * 2.5,
            ),
        ],
      ),
    );
  }
}
