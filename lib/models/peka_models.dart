class CustomerData {
  final String accountId;
  final String status;
  final String statusDescr;
  final String firstName;
  final String lastName;
  final String? pesel;
  final String email;
  final String? street;
  final String? buildNum;
  final String? flatNum;
  final String? postalCode;
  final String? city;
  final String? phone;
  final List<SocialGroup> socialGroups;
  final String mobileId;
  final int loyaltyPoints;
  final bool loyaltyActivated;
  final bool hasPhoto;
  final QrData qr;

  CustomerData({
    required this.accountId,
    required this.status,
    required this.statusDescr,
    required this.firstName,
    required this.lastName,
    this.pesel,
    required this.email,
    this.street,
    this.buildNum,
    this.flatNum,
    this.postalCode,
    this.city,
    this.phone,
    required this.socialGroups,
    required this.mobileId,
    required this.loyaltyPoints,
    required this.loyaltyActivated,
    required this.hasPhoto,
    required this.qr,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      accountId: json['accountId'] as String,
      status: json['status'] as String,
      statusDescr: json['statusDescr'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      pesel: json['pesel'] as String?,
      email: json['email'] as String,
      street: json['street'] as String?,
      buildNum: json['buildNum'] as String?,
      flatNum: json['flatNum'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      socialGroups:
          (json['socialGroups'] as List<dynamic>?)
              ?.map((e) => SocialGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mobileId: json['mobileId'] as String,
      loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
      loyaltyActivated: json['loyaltyActivated'] as bool? ?? false,
      hasPhoto: json['hasPhoto'] as bool? ?? false,
      qr: QrData.fromJson(json['qr'] as Map<String, dynamic>),
    );
  }
}

class SocialGroup {
  final String name;
  final String startDate;
  final String stopDate;

  SocialGroup({
    required this.name,
    required this.startDate,
    required this.stopDate,
  });

  factory SocialGroup.fromJson(Map<String, dynamic> json) {
    return SocialGroup(
      name: json['name'] as String,
      startDate: json['startDate'] as String,
      stopDate: json['stopDate'] as String,
    );
  }
}

class QrData {
  final String signatureDate;
  final String signature;
  final String qrCodeKey;

  QrData({
    required this.signatureDate,
    required this.signature,
    required this.qrCodeKey,
  });

  factory QrData.fromJson(Map<String, dynamic> json) {
    return QrData(
      signatureDate: json['signatureDate'] as String,
      signature: json['signature'] as String,
      qrCodeKey: json['qrCodeKey'] as String,
    );
  }

  // Generate QR code data in format: 61|A.{accountId}.{signatureDate}.{signature}
  String toQrString(String accountId) {
    return '61|A.$accountId.$signatureDate.$signature';
  }
}

class PekaCard {
  final String status;
  final String statusDescr;
  final String number;
  final String category;
  final String categoryDescr;
  final TPurse? tpurse;
  final bool orderDuplicate;
  final bool showTpurseSingleTicket;

  PekaCard({
    required this.status,
    required this.statusDescr,
    required this.number,
    required this.category,
    required this.categoryDescr,
    this.tpurse,
    required this.orderDuplicate,
    required this.showTpurseSingleTicket,
  });

  factory PekaCard.fromJson(Map<String, dynamic> json) {
    return PekaCard(
      status: json['status'] as String,
      statusDescr: json['statusDescr'] as String,
      number: json['number'] as String,
      category: json['category'] as String,
      categoryDescr: json['categoryDescr'] as String,
      tpurse: json['tpurse'] != null
          ? TPurse.fromJson(json['tpurse'] as Map<String, dynamic>)
          : null,
      orderDuplicate: json['orderDuplicate'] as bool? ?? false,
      showTpurseSingleTicket: json['showTpurseSingleTicket'] as bool? ?? false,
    );
  }
}

class TPurse {
  final double balance;
  final double pointsBalance;
  final String updateDate;

  TPurse({
    required this.balance,
    required this.pointsBalance,
    required this.updateDate,
  });

  factory TPurse.fromJson(Map<String, dynamic> json) {
    return TPurse(
      balance: (json['balance'] as num).toDouble(),
      pointsBalance: (json['pointsBalance'] as num).toDouble(),
      updateDate: json['updateDate'] as String,
    );
  }
}

class Ticket {
  final String transactionId;
  final String description;
  final String start;
  final String stop;
  final String discount;
  final String attribute;
  final String zoneGroup;
  final String operator;
  final bool refund;

  Ticket({
    required this.transactionId,
    required this.description,
    required this.start,
    required this.stop,
    required this.discount,
    required this.attribute,
    required this.zoneGroup,
    required this.operator,
    required this.refund,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      transactionId: json['transactionId'] as String,
      description: json['description'] as String,
      start: json['start'] as String,
      stop: json['stop'] as String,
      discount: json['discount'] as String,
      attribute: json['attribute'] as String,
      zoneGroup: json['zoneGroup'] as String,
      operator: json['operator'] as String,
      refund: json['refund'] as bool? ?? false,
    );
  }

  bool get isActive {
    try {
      final stopDate = DateTime.parse(stop.replaceAll(' ', 'T'));
      return stopDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}

class PaymentCard {
  final int loid;
  final String creationDate;
  final String cardNumber;
  final String type;
  final String expDate;

  PaymentCard({
    required this.loid,
    required this.creationDate,
    required this.cardNumber,
    required this.type,
    required this.expDate,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      loid: json['loid'] as int,
      creationDate: json['creationDate'] as String,
      cardNumber: json['cardNumber'] as String,
      type: json['type'] as String,
      expDate: json['expDate'] as String,
    );
  }

  String get formattedType {
    return type.toUpperCase();
  }
}
