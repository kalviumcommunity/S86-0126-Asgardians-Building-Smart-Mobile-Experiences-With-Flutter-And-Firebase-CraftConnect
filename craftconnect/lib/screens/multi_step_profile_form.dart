import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/form_validators.dart';

class MultiStepProfileForm extends StatefulWidget {
  const MultiStepProfileForm({super.key});

  @override
  State<MultiStepProfileForm> createState() => _MultiStepProfileFormState();
}

class _MultiStepProfileFormState extends State<MultiStepProfileForm> {
  final PageController _pageController = PageController();
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  int _currentStep = 0;
  final int _totalSteps = 4;

  // Controllers for Step 1 - Personal Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _bioController = TextEditingController();

  // Controllers for Step 2 - Contact Info
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Controllers for Step 3 - Professional Info
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Controllers for Step 4 - Preferences
  final _salaryExpectationController = TextEditingController();
  final List<String> _selectedSkills = [];
  final List<String> _selectedInterests = [];

  // State variables
  String? _selectedGender;
  String? _selectedState;
  String? _selectedCountry;
  String? _selectedExperienceLevel;
  String? _selectedJobType;
  bool _isWillingToRelocate = false;
  bool _isOpenToRemote = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _experienceController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _salaryExpectationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    return _formKeys[_currentStep].currentState?.validate() ?? false;
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Here you would typically save the data to your backend
    final profileData = {
      'personal': {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'gender': _selectedGender,
        'bio': _bioController.text,
      },
      'contact': {
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _selectedState,
        'country': _selectedCountry,
        'zipCode': _zipCodeController.text,
      },
      'professional': {
        'jobTitle': _jobTitleController.text,
        'company': _companyController.text,
        'experienceLevel': _selectedExperienceLevel,
        'yearsOfExperience': _experienceController.text,
        'website': _websiteController.text,
        'linkedin': _linkedinController.text,
      },
      'preferences': {
        'jobType': _selectedJobType,
        'salaryExpectation': _salaryExpectationController.text,
        'skills': _selectedSkills,
        'interests': _selectedInterests,
        'willingToRelocate': _isWillingToRelocate,
        'openToRemote': _isOpenToRemote,
      },
    };

    print('Profile Data: $profileData');

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8.0),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(_totalSteps, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < _totalSteps - 1 ? 8 : 0,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: index <= _currentStep
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: index <= _currentStep
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStepTitle(index),
                          style: TextStyle(
                            fontSize: 10,
                            color: index <= _currentStep
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            fontWeight: index == _currentStep
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(),
                _buildContactInfoStep(),
                _buildProfessionalInfoStep(),
                _buildPreferencesStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? 'Complete Profile'
                                : 'Next',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Personal';
      case 1:
        return 'Contact';
      case 2:
        return 'Professional';
      case 3:
        return 'Preferences';
      default:
        return '';
    }
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader('Personal Information', 'Tell us about yourself'),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: FormValidators.name,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: FormValidators.name,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _dateOfBirthController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake_outlined),
                hintText: 'MM/DD/YYYY',
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(
                    const Duration(days: 365 * 25),
                  ),
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 365 * 100),
                  ),
                  lastDate: DateTime.now().subtract(
                    const Duration(days: 365 * 13),
                  ),
                );
                if (date != null) {
                  setState(() {
                    _dateOfBirthController.text =
                        '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: ['Male', 'Female', 'Other', 'Prefer not to say']
                  .map(
                    (gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio/About Me',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
                hintText: 'Tell us a bit about yourself...',
              ),
              maxLines: 3,
              maxLength: 500,
              validator: (value) => FormValidators.length(
                value,
                maxLength: 500,
                fieldName: 'Bio',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader('Contact Information', 'How can we reach you?'),

            const SizedBox(height: 24),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: FormValidators.email,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FormFormatters.phoneNumber()],
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: FormValidators.phoneNumber,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ZIP Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State/Province',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'California',
                              'New York',
                              'Texas',
                              'Florida',
                              'Illinois',
                              'Other',
                            ]
                            .map(
                              (state) => DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedState = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'United States',
                              'Canada',
                              'India',
                              'United Kingdom',
                              'Australia',
                              'Other',
                            ]
                            .map(
                              (country) => DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCountry = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Professional Information',
              'Tell us about your career',
            ),

            const SizedBox(height: 24),

            TextFormField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  FormValidators.required(value, fieldName: 'Job title'),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedExperienceLevel,
                    decoration: const InputDecoration(
                      labelText: 'Experience Level *',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'Entry Level',
                              'Junior',
                              'Mid-Level',
                              'Senior',
                              'Lead',
                              'Manager',
                              'Director',
                            ]
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedExperienceLevel = value),
                    validator: (value) =>
                        value == null ? 'Please select experience level' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                      suffixText: 'years',
                    ),
                    validator: (value) =>
                        FormValidators.numeric(value, min: 0, max: 50),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _websiteController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Website/Portfolio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.web_outlined),
                hintText: 'https://yourwebsite.com',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return FormValidators.url(value);
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _linkedinController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'LinkedIn Profile',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_outlined),
                hintText: 'https://linkedin.com/in/yourprofile',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('linkedin.com')) {
                    return 'Please enter a valid LinkedIn URL';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader('Job Preferences', 'What are you looking for?'),

            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: _selectedJobType,
              decoration: const InputDecoration(
                labelText: 'Preferred Job Type *',
                border: OutlineInputBorder(),
              ),
              items:
                  [
                        'Full-time',
                        'Part-time',
                        'Contract',
                        'Freelance',
                        'Internship',
                      ]
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedJobType = value),
              validator: (value) =>
                  value == null ? 'Please select job type' : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _salaryExpectationController,
              keyboardType: TextInputType.number,
              inputFormatters: [FormFormatters.currency()],
              decoration: const InputDecoration(
                labelText: 'Salary Expectation',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                hintText: 'Annual salary in USD',
              ),
            ),

            const SizedBox(height: 16),

            // Skills selection
            _buildMultiSelectField('Skills', [
              'Flutter',
              'React',
              'Node.js',
              'Python',
              'Java',
              'Swift',
              'Kotlin',
              'JavaScript',
              'TypeScript',
              'SQL',
            ], _selectedSkills),

            const SizedBox(height: 16),

            // Interests selection
            _buildMultiSelectField('Interests', [
              'Web Development',
              'Mobile Development',
              'AI/ML',
              'Data Science',
              'Cloud Computing',
              'DevOps',
              'UI/UX',
              'Gaming',
            ], _selectedInterests),

            const SizedBox(height: 16),

            // Preferences switches
            SwitchListTile(
              title: const Text('Open to Remote Work'),
              subtitle: const Text('Would you consider remote positions?'),
              value: _isOpenToRemote,
              onChanged: (value) => setState(() => _isOpenToRemote = value),
            ),

            SwitchListTile(
              title: const Text('Willing to Relocate'),
              subtitle: const Text('Would you consider relocating for work?'),
              value: _isWillingToRelocate,
              onChanged: (value) =>
                  setState(() => _isWillingToRelocate = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField(
    String label,
    List<String> options,
    List<String> selectedItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedItems.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedItems.add(option);
                  } else {
                    selectedItems.remove(option);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
              checkmarkColor: Theme.of(context).primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}
