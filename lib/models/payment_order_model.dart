class PaymentOrderModel {
  final String orderId;
  final int amountPaise;
  final double amountInr;
  final String currency;
  final String keyId;
  final String companyName;
  final String description;
  final Map<String, String> prefill;

  PaymentOrderModel({
    required this.orderId,
    required this.amountPaise,
    required this.amountInr,
    required this.currency,
    required this.keyId,
    required this.companyName,
    required this.description,
    required this.prefill,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      orderId: json['order_id']?.toString() ?? '',
      amountPaise: int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      amountInr: double.tryParse(json['amount_inr']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      keyId: json['key_id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? 'Paarth Holidays',
      description: json['description']?.toString() ?? 'Tour payment',
      prefill: {
        'name': json['prefill']?['name']?.toString() ?? '',
        'email': json['prefill']?['email']?.toString() ?? '',
        'contact': json['prefill']?['contact']?.toString() ?? '',
      },
    );
  }
}
