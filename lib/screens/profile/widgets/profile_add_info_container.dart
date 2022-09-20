import 'package:flutter/material.dart';

class ProfileAddInfoContainer extends StatelessWidget {
  final String text;
  final Function onPress;

  const ProfileAddInfoContainer({required this.text, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: InkWell(
        onTap: () => onPress(),
        child: Container(
          height: 78,
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[900],
                  fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
