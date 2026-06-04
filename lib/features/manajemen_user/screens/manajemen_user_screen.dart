import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/manajemen_user_provider.dart';
import '../../auth/providers/user_provider.dart';

class ManajemenUserScreen extends StatefulWidget {
  const ManajemenUserScreen({Key? key}) : super(key: key);

  @override
  State<ManajemenUserScreen> createState() => _ManajemenUserScreenState();
}

class _ManajemenUserScreenState extends State<ManajemenUserScreen> {
  String _searchQuery = '';
  String _selectedRole = 'Semua Role';

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<ManajemenUserProvider>(context);
    final String currentUserRole = Provider.of<UserProvider>(context, listen: false).currentUser.role;

    // Filter list based on search and role dropdown
    final filteredUsers = userProvider.userList.where((user) {
      final nama = (user['nama'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final role = (user['role'] ?? '').toString().toLowerCase();
      final matchesSearch = nama.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase()) ||
          role.contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == 'Semua Role' || user['role'] == _selectedRole;
      return matchesSearch && matchesRole;
    }).toList();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Summary Cards (2x2 grid on mobile, Row on desktop)
          isMobile
              ? Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildUserCard('Total User', userProvider.totalUser, 'User terdaftar', Icons.people_alt_rounded, AppColors.info, userProvider.totalUserGrowth),
                    ),
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildUserCard('Admin Aktif', userProvider.adminAktif, 'Administrator', Icons.admin_panel_settings_rounded, AppColors.accent, userProvider.adminAktifGrowth),
                    ),
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildUserCard('Pegawai Gudang', userProvider.pegawaiGudang, 'Staff gudang', Icons.warehouse_rounded, AppColors.warning, userProvider.pegawaiGudangGrowth),
                    ),
                    SizedBox(
                      width: (width - 48 - 12) / 2,
                      child: _buildUserCard('Kurir Distribusi', userProvider.kurirDistribusi, 'Driver aktif', Icons.local_shipping_rounded, AppColors.success, userProvider.kurirDistribusiGrowth),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildUserCard('Total User', userProvider.totalUser, 'User terdaftar', Icons.people_alt_rounded, AppColors.info, userProvider.totalUserGrowth)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildUserCard('Admin Aktif', userProvider.adminAktif, 'Administrator', Icons.admin_panel_settings_rounded, AppColors.accent, userProvider.adminAktifGrowth)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildUserCard('Pegawai Gudang', userProvider.pegawaiGudang, 'Staff gudang', Icons.warehouse_rounded, AppColors.warning, userProvider.pegawaiGudangGrowth)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildUserCard('Kurir Distribusi', userProvider.kurirDistribusi, 'Driver aktif', Icons.local_shipping_rounded, AppColors.success, userProvider.kurirDistribusiGrowth)),
                  ],
                ),
          const SizedBox(height: 24),

          // 2. Table Daftar Pengguna
          Card(
            child: Padding(
              padding: isMobile ? const EdgeInsets.all(12) : AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter and Actions (Wrap for mobile)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Daftar Pengguna', style: AppTextStyles.h4),
                          const SizedBox(height: 4),
                          const Text('Kelola semua pengguna sistem dan hak akses', style: AppTextStyles.caption),
                        ],
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          // Search Bar
                          Container(
                            width: isMobile ? double.infinity : 240,
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_rounded, color: AppColors.textLight, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: const InputDecoration(
                                      hintText: 'Cari nama, email...',
                                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textLight),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Role Filter Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRole,
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedRole = newValue;
                                    });
                                  }
                                },
                                items: <String>['Semua Role', 'Owner', 'Admin', 'Staff Gudang', 'Kurir']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddUserDialog(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Tambah User'),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Table (horizontally scrollable)
                  // Table (horizontally scrollable)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      dataRowHeight: 60,
                      headingRowHeight: 50,
                      dividerThickness: 1,
                      showCheckboxColumn: false,
                      columns: [
                        const DataColumn(label: Text('Pengguna', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Email', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Role', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Status', style: AppTextStyles.tableHeader)),
                        const DataColumn(label: Text('Last Login', style: AppTextStyles.tableHeader)),
                        if (currentUserRole == 'Admin')
                          const DataColumn(label: Text('Aksi', style: AppTextStyles.tableHeader))
                        else
                          const DataColumn(label: SizedBox.shrink()),
                      ],
                      rows: filteredUsers.isEmpty
                          ? []
                          : filteredUsers.map((user) {
                              final String nama = user['nama']?.toString() ?? '-';
                              final String idUser = user['id_user']?.toString() ?? '-';
                              final String email = user['email']?.toString() ?? '-';
                              final String role = user['role']?.toString() ?? '-';
                              final String status = user['status']?.toString() ?? '-';
                              final String lastLogin = user['last_login']?.toString() ?? '-';
                              final String firebaseKey = user['key']?.toString() ?? '';

                              final Color roleColor = _getRoleColor(role);
                              final Color statusColor = status == 'Aktif' ? AppColors.success : AppColors.danger;

                              final initials = _getInitials(nama);
                              final avatarColors = _getAvatarColors(role);

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: avatarColors['bg'],
                                          backgroundImage: (user['photoBase64'] != null && user['photoBase64'].toString().isNotEmpty)
                                              ? MemoryImage(base64Decode(user['photoBase64'].toString()))
                                              : (user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty)
                                                  ? NetworkImage(user['photoUrl'].toString())
                                                  : null,
                                          child: ((user['photoBase64'] == null || user['photoBase64'].toString().isEmpty) && 
                                                  (user['photoUrl'] == null || user['photoUrl'].toString().isEmpty))
                                              ? Text(
                                                  initials,
                                                  style: TextStyle(
                                                    color: avatarColors['text'],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                                              Text('ID: $idUser', style: const TextStyle(fontSize: 11, color: AppColors.textLight), overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(email, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: roleColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        role,
                                        style: TextStyle(fontSize: 11, color: roleColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            status,
                                            style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(lastLogin, style: const TextStyle(fontSize: 12, color: AppColors.textLight))),
                                  if (currentUserRole == 'Admin')
                                    DataCell(
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildActionIcon(
                                            Icons.edit_outlined,
                                            AppColors.info,
                                            'Edit',
                                            () => _showEditUserDialog(context, user),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildActionIcon(
                                            Icons.delete_outline,
                                            AppColors.danger,
                                            'Hapus',
                                            () => _confirmDeleteUser(context, firebaseKey, nama),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    const DataCell(SizedBox.shrink()),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                  if (filteredUsers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textLight.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          const Text('Tidak ada pengguna yang cocok dengan kriteria filter.', style: AppTextStyles.caption),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Pagination (Wrap for mobile safety)
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Text('Menampilkan 1-${filteredUsers.length} dari ${filteredUsers.length} data', style: AppTextStyles.caption),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: null,
                            child: const Text('Prev'),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(36, 36),
                            ),
                            child: const Text('1'),
                          ),
                          OutlinedButton(
                            onPressed: null,
                            child: const Text('Next'),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ===========================================================================
  // SUMMARY CARD WIDGET
  // ===========================================================================

  Widget _buildUserCard(String title, String value, String subtitle, IconData icon, Color color, String badge) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppTextStyles.cardValue),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(title, style: AppTextStyles.caption),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(subtitle, style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================


  Widget _buildActionIcon(IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  // ===========================================================================
  // IMAGE PICKER & BASE64 CONVERSION HELPERS
  // ===========================================================================
  Future<void> _pickAndConvertImage(
    BuildContext dialogContext,
    StateSetter setDialogState,
    ImageSource source,
    Function(String) onConversionSuccess,
    Function(bool) onUploadProgress,
  ) async {
    final ImagePicker picker = ImagePicker();
    try {
      onUploadProgress(true);
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 200,
        imageQuality: 50,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        onConversionSuccess(base64String);
      }
    } catch (e) {
      if (dialogContext.mounted) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      onUploadProgress(false);
    }
  }

  void _showImageSourceSheet(BuildContext dialogContext, StateSetter setDialogState, Function(String) onUploadSuccess, Function(bool) onUploadProgress) {
    showModalBottomSheet(
      context: dialogContext,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndConvertImage(dialogContext, setDialogState, ImageSource.gallery, onUploadSuccess, onUploadProgress);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndConvertImage(dialogContext, setDialogState, ImageSource.camera, onUploadSuccess, onUploadProgress);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // ADD USER DIALOG
  // ===========================================================================

  void _showAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Staff Gudang';
    String selectedStatus = 'Aktif';

    String? photoBase64;
    bool isUploading = false;
    final String userId = context.read<ManajemenUserProvider>().generateUserId();

    showDialog(
      context: context,
      builder: (ctx) {
        final fieldBg = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background;
        final fieldBorder = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border;

        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_add_rounded, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Tambah User Baru', style: AppTextStyles.h4),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(45),
                              onTap: isUploading
                                  ? null
                                  : () => _showImageSourceSheet(
                                        context,
                                        setDialogState,
                                        (base64Str) => setDialogState(() => photoBase64 = base64Str),
                                        (uploading) => setDialogState(() => isUploading = uploading),
                                      ),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: fieldBg,
                                backgroundImage: (photoBase64 != null && photoBase64!.isNotEmpty)
                                    ? MemoryImage(base64Decode(photoBase64!))
                                    : null,
                                child: (photoBase64 == null || photoBase64!.isEmpty)
                                    ? const Icon(Icons.camera_alt, size: 30, color: AppColors.textLight)
                                    : null,
                              ),
                            ),
                            if (isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Nama Lengkap
                      TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Nama tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong';
                          if (!val.contains('@') || !val.contains('.')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Role',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        items: ['Owner', 'Admin', 'Staff Gudang', 'Kurir']
                            .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedRole = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.toggle_on_outlined, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        items: ['Aktif', 'Nonaktif']
                            .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedStatus = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final provider = context.read<ManajemenUserProvider>();
                      final data = {
                        'nama': namaController.text.trim(),
                        'email': emailController.text.trim(),
                        'id_user': userId,
                        'role': selectedRole,
                        'status': selectedStatus,
                        'last_login': 'Belum pernah',
                        'photoBase64': photoBase64 ?? '',
                      };

                      Navigator.pop(ctx);
                      final success = await provider.addUser(data);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'User "${ namaController.text.trim()}" berhasil ditambahkan' : 'Gagal menambahkan user'),
                            backgroundColor: success ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data yang diinputkan tidak sesuai. Periksa kembali form Anda.'),
                          backgroundColor: AppColors.danger,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // EDIT USER DIALOG
  // ===========================================================================

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: user['nama']?.toString() ?? '');
    final emailController = TextEditingController(text: user['email']?.toString() ?? '');
    String selectedRole = user['role']?.toString() ?? 'Staff Gudang';
    String selectedStatus = user['status']?.toString() ?? 'Aktif';
    final String firebaseKey = user['key']?.toString() ?? '';
    final String userId = user['id_user']?.toString() ?? '';

    String? photoBase64 = user['photoBase64']?.toString();
    bool isUploading = false;

    // Validate role/status values to prevent dropdown crash
    if (!['Owner', 'Admin', 'Staff Gudang', 'Kurir'].contains(selectedRole)) {
      selectedRole = 'Staff Gudang';
    }
    if (!['Aktif', 'Nonaktif'].contains(selectedStatus)) {
      selectedStatus = 'Aktif';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final fieldBg = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF111827) : AppColors.background;
        final fieldBorder = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF374151) : AppColors.border;

        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_rounded, color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit User', style: AppTextStyles.h4),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(45),
                              onTap: isUploading
                                  ? null
                                  : () => _showImageSourceSheet(
                                        context,
                                        setDialogState,
                                        (base64Str) => setDialogState(() => photoBase64 = base64Str),
                                        (uploading) => setDialogState(() => isUploading = uploading),
                                      ),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: fieldBg,
                                backgroundImage: (photoBase64 != null && photoBase64!.isNotEmpty)
                                    ? MemoryImage(base64Decode(photoBase64!))
                                    : (user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty)
                                        ? NetworkImage(user['photoUrl'].toString())
                                        : null,
                                child: ((photoBase64 == null || photoBase64!.isEmpty) &&
                                        (user['photoUrl'] == null || user['photoUrl'].toString().isEmpty))
                                    ? const Icon(Icons.camera_alt, size: 30, color: AppColors.textLight)
                                    : null,
                              ),
                            ),
                            if (isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Nama Lengkap
                      TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Nama tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong';
                          if (!val.contains('@') || !val.contains('.')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Role',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        items: ['Owner', 'Admin', 'Staff Gudang', 'Kurir']
                            .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedRole = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : AppColors.surface,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: AppTextStyles.caption,
                          prefixIcon: const Icon(Icons.toggle_on_outlined, size: 20),
                          filled: true,
                          fillColor: fieldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                        items: ['Aktif', 'Nonaktif']
                            .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedStatus = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final data = {
                        'nama': namaController.text.trim(),
                        'email': emailController.text.trim(),
                        'role': selectedRole,
                        'status': selectedStatus,
                         'photoBase64': photoBase64 ?? '',
                      };

                      Navigator.pop(ctx);
                      final success = await context.read<ManajemenUserProvider>().updateUser(firebaseKey, data);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Data user berhasil diperbarui' : 'Gagal memperbarui data'),
                            backgroundColor: success ? AppColors.success : AppColors.danger,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data yang diinputkan tidak sesuai. Periksa kembali form Anda.'),
                          backgroundColor: AppColors.danger,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Simpan Perubahan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // DELETE CONFIRMATION DIALOG
  // ===========================================================================

  void _confirmDeleteUser(BuildContext context, String key, String nama) {
    if (key.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Hapus User', style: AppTextStyles.h4),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              const TextSpan(text: 'Apakah Anda yakin ingin menghapus user '),
              TextSpan(text: '"$nama"', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ManajemenUserProvider>().deleteUser(key);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'User "$nama" berhasil dihapus' : 'Gagal menghapus user'),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Owner':
        return AppColors.accent;    // Purple
      case 'Admin':
        return AppColors.info;      // Blue
      case 'Staff Gudang':
        return AppColors.warning;   // Orange
      case 'Kurir':
        return AppColors.success;   // Green
      default:
        return AppColors.textLight;
    }
  }

  Map<String, Color> _getAvatarColors(String role) {
    switch (role) {
      case 'Owner':
        return {'bg': const Color(0xFFFDE68A), 'text': const Color(0xFFD97706)};
      case 'Admin':
        return {'bg': const Color(0xFFBFDBFE), 'text': const Color(0xFF1E3A8A)};
      case 'Staff Gudang':
        return {'bg': const Color(0xFFFDE68A), 'text': const Color(0xFFD97706)};
      case 'Kurir':
        return {'bg': const Color(0xFFA7F3D0), 'text': const Color(0xFF065F46)};
      default:
        return {'bg': const Color(0xFFE5E7EB), 'text': const Color(0xFF374151)};
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}