import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/hashtag.dart';
import '../../l10n/app_strings.dart';
import '../../providers/hashtag_provider.dart';

class UnlockScreen extends StatefulWidget {
  final Hashtag hashtag;
  const UnlockScreen({super.key, required this.hashtag});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _controller = TextEditingController();
  final _auth = LocalAuthentication();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return;
      final ok = await _auth.authenticate(
        localizedReason: context.mounted ? context.tr('biometricReason') : 'Authenticate',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (ok && mounted) {
        context.read<HashtagProvider>().markUnlocked(widget.hashtag);
        Navigator.pop(context, true);
      }
    } catch (_) {
      // Biometric unavailable/cancelled — the user can still use the password field.
    }
  }

  void _submitPassword() {
    final hp = context.read<HashtagProvider>();
    if (hp.verifyPassword(widget.hashtag, _controller.text)) {
      hp.markUnlocked(widget.hashtag);
      Navigator.pop(context, true);
    } else {
      setState(() => _error = context.tr('wrongPassword'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(widget.hashtag.colorHex);

    return Scaffold(
      appBar: AppBar(title: Text('#${widget.hashtag.name}')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(color: color.withOpacity(0.14), shape: BoxShape.circle),
                child: Icon(Icons.lock, size: 38, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('lockedHashtagDesc'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: context.tr('enterPassword'),
                  errorText: _error,
                ),
                onSubmitted: (_) => _submitPassword(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _submitPassword, child: Text(context.tr('unlock'))),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _tryBiometric,
                icon: const Icon(Icons.fingerprint),
                label: Text(context.tr('useBiometric')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
