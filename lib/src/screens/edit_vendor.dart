import 'dart:async';
import 'dart:io';

import 'package:farmersmarket/src/blocs/auth_bloc.dart';
import 'package:farmersmarket/src/blocs/vendor_bloc.dart';
import 'package:farmersmarket/src/models/vendor.dart';
import 'package:farmersmarket/src/styles/base.dart';
import 'package:farmersmarket/src/styles/colors.dart';
import 'package:farmersmarket/src/styles/text.dart';
import 'package:farmersmarket/src/widgets/button.dart';
import 'package:farmersmarket/src/widgets/sliver_scaffold.dart';
import 'package:farmersmarket/src/widgets/textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class EditVendor extends StatefulWidget {
  final String? vendorId;

  EditVendor({this.vendorId});

  @override
  _EditVendorState createState() => _EditVendorState();
}

class _EditVendorState extends State<EditVendor> {
  StreamSubscription? _savedSubscription;
  @override
  void initState() {
    var vendorBloc = Provider.of<VendorBloc>(context, listen: false);
    _savedSubscription = vendorBloc.vendorSaved.listen((saved) {
      if (saved == true) {
        Fluttertoast.showToast(
            msg: "Vendor Saved",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: AppColors.lightblue,
            textColor: Colors.white,
            fontSize: 16.0);

        Navigator.of(context).pop();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _savedSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var vendorBloc = Provider.of<VendorBloc>(context);
    var authBloc = Provider.of<AuthBloc>(context);

    return StreamBuilder<Vendor>(
      stream: vendorBloc.vendor,
      builder: (context, snapshot) {
        if (!snapshot.hasData && widget.vendorId != null) {
          return Scaffold(
            body: Center(
                child: (Platform.isIOS)
                    ? CupertinoActivityIndicator()
                    : CircularProgressIndicator()),
          );
        }

        Vendor vendor = snapshot.data!;

        //Edit Logic
        loadValues(vendorBloc, vendor, authBloc.userId);

        return (Platform.isIOS)
            ? AppSliverScaffold.cupertinoSliverScaffold(
                navTitle: '',
                pageBody: pageBody(true, vendorBloc, context, vendor),
                context: context)
            : AppSliverScaffold.materialSliverScaffold(
                navTitle: '',
                pageBody: pageBody(false, vendorBloc, context, vendor),
                context: context);
      },
    );
  }

  Widget pageBody(bool isIOS, VendorBloc vendorBloc, BuildContext context,
      Vendor existingVendor) {
    var pageLabel = (existingVendor != null) ? 'Edit Profile' : 'Add Profile';
    return ListView(
      children: <Widget>[
        Text(
          pageLabel,
          style: TextStyles.subtitle,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: BaseStyles.listPadding,
          child: Divider(color: AppColors.darkblue),
        ),
        StreamBuilder<String>(
            stream: vendorBloc.name,
            builder: (context, snapshot) {
              return AppTextField(
                hintText: 'Vendor Name',
                cupertinoIcon: FontAwesomeIcons.shoppingBasket,
                materialIcon: FontAwesomeIcons.shoppingBasket,
                isIOS: isIOS,
                errorText: '${snapshot.error}',
                initialText: existingVendor.name!,
                onChanged: vendorBloc.changeName,
              );
            }),
        StreamBuilder<String>(
            stream: vendorBloc.description,
            builder: (context, snapshot) {
              return AppTextField(
                hintText: 'Description',
                cupertinoIcon: FontAwesomeIcons.shoppingBasket,
                materialIcon: FontAwesomeIcons.shoppingBasket,
                isIOS: isIOS,
                errorText: '${snapshot.error}',
                initialText: existingVendor.description!,
                onChanged: vendorBloc.changeDescription,
              );
            }),
        StreamBuilder<bool>(
          stream: vendorBloc.isUploading,
          builder: (context, snapshot) {
            return (!snapshot.hasData || snapshot.data == false)
                ? Container()
                : Center(
                    child: (Platform.isIOS)
                        ? CupertinoActivityIndicator()
                        : CircularProgressIndicator(),
                  );
          },
        ),
        StreamBuilder<String>(
            stream: vendorBloc.imageUrl,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == "")
                return AppButton(
                  buttonType: ButtonType.Straw,
                  buttonText: 'Add Image',
                  onPressed: vendorBloc.pickImage,
                );

              return Column(
                children: <Widget>[
                  Padding(
                    padding: BaseStyles.listPadding,
                    child: Image.network(snapshot.data!),
                  ),
                  AppButton(
                    buttonType: ButtonType.Straw,
                    buttonText: 'Change Image',
                    onPressed: vendorBloc.pickImage,
                  )
                ],
              );
            }),
        StreamBuilder<bool>(
            stream: vendorBloc.isValid,
            builder: (context, snapshot) {
              return AppButton(
                buttonType: (snapshot.data == true)
                    ? ButtonType.DarkBlue
                    : ButtonType.Disabled,
                buttonText: 'Save Profile',
                onPressed: vendorBloc.saveVendor,
              );
            }),
      ],
    );
  }

  loadValues(VendorBloc vendorBloc, Vendor vendor, String vendorId) {
    vendorBloc.changeVendorId(vendorId);

    //Edit
    vendorBloc.changeName(vendor.name!);
    vendorBloc.changeDescription(vendor.description!);
    vendorBloc.changeImageUrl(vendor.imageUrl!);
  }
}
