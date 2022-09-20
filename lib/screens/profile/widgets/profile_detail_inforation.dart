import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../values/color-helper.dart';
import '../../../screens/profile/widgets/tag_widget.dart';
import '../../../screens/profile/gql/profile.gql.dart';
import '../../../screens/celebration/widgets/email-resend-success.dart';

class ProfileDetailInformation extends StatelessWidget {
  final Map<String, dynamic> data;

  ProfileDetailInformation(this.data);

  @override
  Widget build(BuildContext context) {
    var formatString = "yyyy-MM-ddThh:mm:ssZ";
    String date = '. . .';
    var userId = data['id'];
    var userEmail = data['email'];
    if (data['dateOfBirth'] != null) {
      DateTime format1 = new DateFormat(formatString)
          .parse(data['dateOfBirth'], true)
          .toLocal();
      date = DateFormat("dd MMM, yyyy").format(format1);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/icon_phone.svg',
                width: 22,
                height: 22,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                'Profile.Mobile'.tr(),
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
              SizedBox(
                width: 4,
              ),
              Visibility(
                  visible: false,
                  child: Icon(
                    Icons.check,
                    color: primaryColor,
                    size: 16,
                  )),
              Expanded(
                child: Text(
                  data['phone'],
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          _divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/icon_mail.svg',
                width: 22,
                height: 22,
              ),
              SizedBox(
                width: 16,
              ),
              Text(
                'Profile.Email'.tr(),
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
              SizedBox(
                width: 4,
              ),
              Visibility(
                  visible: false,
                  child: Icon(
                    Icons.check,
                    color: primaryColor,
                    size: 16,
                  )),
              Expanded(
                child: Text(
                  data['email'],
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.grey[600]),
                ),
              )
            ],
          ),
          // For future work
          SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Query(
                  options: QueryOptions(
                      document: gql(ProfileGQL.GET_EMAIL_VERIFICATION),
                      variables: {'userId': userId},
                      optimisticResult: QueryResult.optimistic(),
                      fetchPolicy: FetchPolicy.cacheAndNetwork),
                  builder: (QueryResult result,
                      {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (result.data != null) {
                      bool isVerified = result
                              .data!["GetEmailVerificationStatus"][
                          "verificationStatus"]; //database column or return value from api
                      return isVerified != true
                          ? Mutation(
                              options: MutationOptions(
                                document: gql(ProfileGQL.RESEND_EMAIL),
                                onCompleted: (dynamic resultData) {
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => Dialog(
                                            child: EmailResendSuccess(),
                                            backgroundColor: Colors.transparent,
                                            insetPadding: EdgeInsets.all(24),
                                          ));
                                },
                                onError: (dynamic resultData) {
                                  print(resultData);
                                },
                              ),
                              builder: (
                                RunMutation runMutation,
                                QueryResult? result,
                              ) {
                                return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          runMutation({"userId": userEmail});
                                        },
                                        child: Text(
                                            'Profile.SendEmailVerification'
                                                .tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 10,
                                                    color: Colors.grey[900],
                                                    decoration: TextDecoration
                                                        .underline)),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: TagWidget(
                                          text: 'Not Verified',
                                          backgroundColor: Color(0xFFFF906D),
                                          textColor: Colors.black,
                                          textSize: 10,
                                        ),
                                      ),
                                    ]);
                              })
                          : Container(width: 0.0, height: 0.0);
                    } else {
                      return Container(width: 0.0, height: 0.0);
                    }
                  }),
            ],
          ),
          _divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SvgPicture.asset(
                'assets/images/icon_cake.svg',
                width: 22,
                height: 22,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                'Profile.Birthday'.tr(),
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    fontWeight: FontWeight.normal, color: Colors.grey[900]),
              ),
              SizedBox(
                width: 4,
              ),
              Visibility(
                  visible: false,
                  child: Icon(
                    Icons.check,
                    color: primaryColor,
                    size: 20,
                  )),
              Expanded(
                child: Text(
                  date,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Widget _divider() {
    return Column(
      children: [
        SizedBox(
          height: 14,
        ),
        Divider(
          height: 1,
          color: Colors.grey[400],
        ),
        SizedBox(
          height: 14,
        ),
      ],
    );
  }
}
