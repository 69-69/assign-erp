import 'package:assign_erp/core/constants/app_constant.dart';

class OnBoardingModel {
  String title, subtitle, imageLink;
  OnBoardingModel({
    required this.title,
    required this.subtitle,
    required this.imageLink,
  });
}

class OnBoardingData {
  static List<OnBoardingModel> boards = [
    OnBoardingModel(
      title: 'ERP Software for Business',
      subtitle:
          'A complete solution to streamline operations — manage finance, HR, procurement, and workflows in a single integrated system.',
      imageLink: onBoardingBg1,
    ),
    OnBoardingModel(
      title: 'Available on Desktop, Mobile, Web & Cloud',
      subtitle:
          'Access your ERP system anytime, anywhere — ensure business continuity and collaboration across devices and multiple locations.',
      imageLink: onBoardingBg2,
    ),
    OnBoardingModel(
      title: 'Inventory Management Software',
      subtitle:
          'Track stock levels, manage warehouses, and automate reordering — gain real-time visibility into your inventory across locations.',
      imageLink: onBoardingBg3,
    ),
    OnBoardingModel(
      title: 'Point of Sale (POS) System',
      subtitle:
          'Connect your sales channels directly with inventory and accounting — enable fast, secure, and synchronized in-store transactions.',
      imageLink: onBoardingBg4,
    ),
    OnBoardingModel(
      title: 'Customer Relationship Management (CRM)',
      subtitle:
          'Manage leads, sales, and customer support in one place — build stronger relationships and drive repeat business with smart automation.',
      imageLink: onBoardingBg5,
    ),
  ];
}
