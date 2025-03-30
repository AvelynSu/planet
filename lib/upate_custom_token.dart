// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:planet/custom_theme.dart';
// import 'package:planet/repository/fb_repository.dart';
// import 'package:planet/ui/common/base_scaffold.dart';
// import 'package:planet/ui/common/default_button.dart';
//
// class UpateCustomToken extends StatefulWidget {
//   const UpateCustomToken({super.key});
//
//   @override
//   State<UpateCustomToken> createState() => _UpateCustomTokenState();
// }
//
// class _UpateCustomTokenState extends State<UpateCustomToken> {
//   @override
//   Widget build(BuildContext context) {
//     return BaseScaffold(
//       body: Container(
//         padding: EdgeInsets.symmetric(horizontal: hPadding),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             DefaultButton(
//               title: "",
//               onTap: () {
//                 var api = context.read<ApiRepository>();
//                 api.updateCustomtoken();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
