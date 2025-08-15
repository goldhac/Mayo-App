import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mayo_fixed/services/auth_service.dart';
import 'package:mayo_fixed/services/database_service.dart';
import 'package:mayo_fixed/widgets/linked_partner_widget.dart';

class PartnerLinkScreen extends StatefulWidget {
  const PartnerLinkScreen({super.key});

  @override
  State<PartnerLinkScreen> createState() => _PartnerLinkScreenState();
}

class _PartnerLinkScreenState extends State<PartnerLinkScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _partnerCodeController = TextEditingController();

  bool _isLoading = true;
  String _userPartnerCode = '';
  String _userId = '';
  bool _isSubmitting = false;
  bool _isLinked = false;
  String? _partnerId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _partnerCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userResult = await _databaseService.getUserData(user.uid);
        if (userResult.success && userResult.data != null) {
          final userData = userResult.data as Map<String, dynamic>;

          if (userData['partnerId'] != null) {
            if (mounted) {
              setState(() {
                _isLinked = true;
                _partnerId = userData['partnerId'] as String;
                _userId = user.uid;
                _isLoading = false;
              });
            }
            return;
          }

          // Prefer retrieving existing partner code, fallback to generating
          final codeResult =
              await _databaseService.getUserPartnerCode(user.uid);
          if (codeResult.success && codeResult.data != null) {
            final partnerData = codeResult.data as Map<String, dynamic>;
            if (mounted) {
                setState(() {
                  _userPartnerCode = partnerData['partnerCode'] as String;
                  _userId = partnerData['userId'] as String;
                });
              }
          } else {
            final genResult =
                await _databaseService.generatePartnerCode(user.uid);
            if (genResult.success && genResult.data != null) {
              final partnerData = genResult.data as Map<String, dynamic>;
              setState(() {
                _userPartnerCode = partnerData['partnerCode'] as String;
                _userId = partnerData['userId'] as String;
              });
            } else {
              if (mounted) {
                setState(() {
                  _errorMessage =
                      'Failed to generate partner code: ${genResult.message}';
                });
              }
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading user data: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyPartnerCode() {
    Clipboard.setData(ClipboardData(text: _userPartnerCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partner code copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _linkWithPartner() async {
    final partnerCode = _partnerCodeController.text.trim();
    if (partnerCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a partner code';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final result =
            await _databaseService.linkWithPartner(user.uid, partnerCode);
        if (result.success) {
          _partnerCodeController.clear();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(result.message), backgroundColor: Colors.green),
            );
          }
          if (mounted) Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = result.message;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error linking partner: $e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Couple Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isLinked
              ? LinkedPartnerWidget(
                  userId: _userId,
                  partnerId: _partnerId!,
                  onPartnerUnlinked: () {
                    // Reset state when partner is unlinked
                    setState(() {
                      _isLinked = false;
                      _partnerId = null;
                    });
                    // Reload user data to get partner code
                    _loadUserData();
                  },
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Manage your linked partner to share the experience",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            const Text(
                              'Your Partner Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Text(
                                      _userPartnerCode.isEmpty
                                          ? 'Generating...'
                                          : _userPartnerCode,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _userPartnerCode.isEmpty
                                      ? null
                                      : _copyPartnerCode,
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Link with Partner',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter your partner\'s 5-character code below to link your accounts.',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _partnerCodeController,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[A-Za-z0-9]')),
                                LengthLimitingTextInputFormatter(5),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Enter partner code',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.purple, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.link),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _linkWithPartner,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text('Link Partner'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
