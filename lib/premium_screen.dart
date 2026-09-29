import 'package:flutter/material.dart';
import 'paystack_service.dart';
import 'premium_store.dart';

class _Tutor3DMaterialIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> colors;

  const _Tutor3DMaterialIcon({
    required this.icon,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 7,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            top: 6,
            child: Icon(
              icon,
              size: size,
              color: const Color(0xFF12345F),
            ),
          ),
          Positioned(
            left: 2,
            top: 3,
            child: Icon(
              icon,
              size: size,
              color: const Color(0xFF2D5E9E),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(
              icon,
              size: size,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TutorPaystackService _paystackService = TutorPaystackService();
  final TutorPremiumStore _premiumStore = TutorPremiumStore();

  String _selectedPlan = 'monthly';
  bool _processing = false;

  static const Map<String, String> _planNames = <String, String>{
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
  };

  static const Map<String, int> _planAmounts = <String, int>{
    'weekly': 1000,
    'monthly': 2000,
    'yearly': 25000,
  };
  @override
  void initState() {
    super.initState();
    _loadPremiumState();
  }

  Future<void> _loadPremiumState() async {
    await _premiumStore.load();

    if (!mounted) return;

    if (_premiumStore.email.isNotEmpty) {
      _emailController.text = _premiumStore.email;
    }

    setState(() {});
  }
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (_processing) return;

    if (_premiumStore.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium is already active on this device.'),
        ),
      );
      return;
    }

    final email = _emailController.text.trim();

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the email address you will use for Paystack.'),
        ),
      );
      return;
    }

    setState(() => _processing = true);

    final result = await _paystackService.startSubscription(
      email: email,
      plan: _selectedPlan,
    );

    if (!mounted) return;

    setState(() => _processing = false);

    if (result.success) {
      final verification = result.verification;
      final verifiedEmail =
          verification?['customerEmail']?.toString().trim().toLowerCase() ?? '';
      final verifiedCurrency =
          verification?['currency']?.toString().trim().toUpperCase() ?? '';
      final verifiedAmount =
          int.tryParse(verification?['amount']?.toString() ?? '') ?? 0;
      final expectedAmount = (_planAmounts[_selectedPlan] ?? 0) * 100;

      final paymentMatchesPlan =
          verifiedEmail == email.trim().toLowerCase() &&
          verifiedCurrency == 'NGN' &&
          verifiedAmount == expectedAmount &&
          result.reference.trim().isNotEmpty;

      if (!paymentMatchesPlan) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification details did not match the selected Premium plan. '
              'Premium was not activated.',
            ),
          ),
        );
        return;
      }

            await _premiumStore.activate(
        plan: _selectedPlan,
        email: email,
        reference: result.reference,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Premium activated'),
            content: Text(
              'Your TutorAI ${_planNames[_selectedPlan]} subscription was verified successfully.\n\n'
              'Reference: ${result.reference}',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
      ),
    );
  }

  Widget _buildPremiumStatusCard() {
    final active = _premiumStore.isActive;
    final planLabel = _planNames[_premiumStore.plan] ??
        (_premiumStore.plan.isEmpty ? 'Unknown' : _premiumStore.plan);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? const Color(0xFF2E7D32)
              : const Color(0xFFF9A825),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tutor3DMaterialIcon(
            icon: active
                ? Icons.verified_rounded
                : Icons.workspace_premium_rounded,
            size: 30,
            colors: active
                ? const [
                    Color(0xFF86EFAC),
                    Color(0xFF22C55E),
                    Color(0xFF15803D),
                  ]
                : const [
                    Color(0xFFFFF176),
                    Color(0xFFFFC107),
                    Color(0xFFFF9800),
                  ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? 'PREMIUM ACTIVE' : 'PREMIUM NOT ACTIVE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: active
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFF6D4C41),
                  ),
                ),
                const SizedBox(height: 6),
                if (active) ...[
                  Text(
                    'Plan: $planLabel',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Email: ${_premiumStore.email}',
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Payment reference: ${_premiumStore.reference}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else
                  const Text(
                    'No active Premium subscription is currently saved on this device.',
                    style: TextStyle(fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TutorAI Premium'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 64,
          ),
          const SizedBox(height: 14),
          const Text(
            'Upgrade to TutorAI Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get premium access to TutorAI learning tools and study features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          _buildPremiumStatusCard(),
          const SizedBox(height: 18),
          const Text(
            'Choose your plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._planNames.entries.map(
            (entry) {
              final plan = entry.key;
              final selected = _selectedPlan == plan;
              final amount = _planAmounts[plan]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: RadioListTile<String>(
                    value: plan,
                    groupValue: _selectedPlan,
                    onChanged: _processing || _premiumStore.isActive
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() => _selectedPlan = value);
                          },
                    title: Text(
                      entry.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      '₦${amount.toString()} ${plan == 'weekly' ? 'per week' : plan == 'monthly' ? 'per month' : 'per year'}',
                    ),
                    secondary: selected
                        ? const Icon(Icons.check_circle_rounded)
                        : const Icon(Icons.radio_button_unchecked_rounded),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'Paystack email',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_processing,
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'student@example.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Use the same email address you want Paystack to use for this subscription.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: (_processing || _premiumStore.isActive) ? null : _startPayment,
              icon: _processing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.lock_rounded),
              label: Text(
                _processing
                    ? 'Processing...'
                    : (_premiumStore.isActive ? 'PREMIUM ACTIVE' : 'Continue to Payment'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}