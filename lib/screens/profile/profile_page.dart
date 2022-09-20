import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gem_consumer_app/providers/auth.dart';
import 'package:gem_consumer_app/screens/profile/gql/profile.gql.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_detail_inforation.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_diner_profile.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_information_card.dart';
import 'package:gem_consumer_app/screens/profile/widgets/profile_special_occasions.dart';
import 'package:gem_consumer_app/widgets/loading_controller.dart';
import '../../UI/Layout/custom_app_bar.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static String routeName = '/profile';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static late Auth auth;

  @override
  void initState() {
    auth = context.read<Auth>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(size.width, 60),
        child: CustomAppBar(
          text: 'AccountPage.Profile'.tr(),
        ),
      ),
      body: Query(
        options: QueryOptions(
            document: gql(ProfileGQL.GET_USER_INFO),
            variables: {'userId': auth.currentUser.id},
            optimisticResult: QueryResult.optimistic(),
            fetchPolicy: FetchPolicy.networkOnly),
        builder: (QueryResult? result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result!.isLoading) {
            return LoadingController();
          }

          if (result.data != null) {
            return SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileInformationCard(result.data!['currentUser'],
                      (value) => onReloadPage(value)),
                  ProfileDetailInformation(result.data!['currentUser']),
                  _buildDivider(),
                  ProfileSpecialOccasion(result.data!['currentUser'],
                      (value) => onReloadPage(value)),
                  _buildDivider(),
                  ProfileDinerProfile(result.data!['currentUser'],
                      (value) => onReloadPage(value))
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  void onReloadPage(dynamic value) {
    if (value != null) {
      setState(() {});
    }
  }

  Widget _buildDivider() {
    return Container(
      height: 10,
      color: Colors.grey[100],
    );
  }
}
