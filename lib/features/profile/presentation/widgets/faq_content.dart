import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A group of help questions shown on the FAQ screen.
class FaqCategory {
  const FaqCategory(this.title, this.icon, this.accent, this.entries);

  final String title;
  final IconData icon;
  final FeatureAccent accent;
  final List<FaqEntry> entries;
}

class FaqEntry {
  const FaqEntry(this.question, this.answer);

  final String question;
  final String answer;

  bool matches(String query) =>
      question.toLowerCase().contains(query) || answer.toLowerCase().contains(query);
}

const faqCategories = [
  FaqCategory('Getting started', Icons.rocket_launch_outlined, FeatureAccent.pets, [
    FaqEntry(
      'How do I add a pet?',
      'Open the Pets tab and tap “Add Pet”. Only the name and species are required — '
          'you can add a photo, breed, birthday, weight and microchip number now or later.',
    ),
    FaqEntry(
      'Can I manage more than one pet?',
      'Yes, there’s no limit. The Home dashboard, calendar and reminders cover all your '
          'pets, and most lists can be filtered by pet.',
    ),
    FaqEntry(
      'How do I change my name, phone or photo?',
      'Go to Profile → Edit profile. Your email address is your login, so it can’t be '
          'changed there.',
    ),
  ]),
  FaqCategory('Reminders', Icons.notifications_active_outlined, FeatureAccent.appointments, [
    FaqEntry(
      'Why am I not getting reminders?',
      'Check that notifications are allowed for PetCare in your phone’s settings, and that '
          'the reminder type is switched on in Profile → Notifications. Some phones also pause '
          'apps in battery-saver mode; excluding PetCare from battery optimisation helps.',
    ),
    FaqEntry(
      'When are reminders sent?',
      'Vaccination and appointment reminders use the timing you pick on each record, and '
          'medication reminders arrive at every dose time. Profile → Notifications turns each '
          'type on or off.',
    ),
    FaqEntry(
      'Do reminders work without internet?',
      'Yes. Reminders are scheduled on your phone, so they arrive even when you’re offline.',
    ),
  ]),
  FaqCategory('Health records', Icons.vaccines_outlined, FeatureAccent.vaccinations, [
    FaqEntry(
      'How is the next vaccination date worked out?',
      'When you pick a common vaccine, PetCare suggests the usual interval (for example one '
          'year for rabies). You can always change the due date yourself.',
    ),
    FaqEntry(
      'What documents can I upload?',
      'Photos and PDFs up to 10 MB — vaccination cards, lab results, X-rays, prescriptions '
          'and more. PDFs open right inside the app.',
    ),
    FaqEntry(
      'Can I track my pet’s weight?',
      'Yes. Open a pet and choose Weight to log weigh-ins and see the trend on a chart.',
    ),
  ]),
  FaqCategory('Emergency QR', Icons.qr_code_2, FeatureAccent.emergency, [
    FaqEntry(
      'What does the QR code do?',
      'Anyone who scans your pet’s QR tag sees an emergency page with the details you chose '
          'to share, such as your phone number and medical warnings — no app or account needed.',
    ),
    FaqEntry(
      'What information is public?',
      'Only the fields you switch on in the pet’s Emergency profile. You can turn the public '
          'page off at any time and the code stops working immediately.',
    ),
  ]),
  FaqCategory('Offline & sync', Icons.cloud_sync_outlined, FeatureAccent.clinics, [
    FaqEntry(
      'Can I use PetCare offline?',
      'Yes. Everything you’ve opened before stays available, and changes you make offline are '
          'saved on your phone and synced automatically when you reconnect. Photo and document '
          'uploads need a connection.',
    ),
    FaqEntry(
      'What does “Pending sync” mean?',
      'That change is saved on your phone but hasn’t reached the cloud yet. It will sync on '
          'its own once you’re back online.',
    ),
  ]),
  FaqCategory('Account & privacy', Icons.shield_outlined, FeatureAccent.medications, [
    FaqEntry(
      'Who can see my data?',
      'Only you. Your records are stored in your private account and protected by security '
          'rules; the only exception is an Emergency QR page you choose to publish.',
    ),
    FaqEntry(
      'How do I change my password?',
      'Profile → Change password. If you signed up with Google, your password is managed by '
          'your Google account instead.',
    ),
    FaqEntry(
      'How do I delete my account?',
      'Profile → Delete account. This permanently removes your pets, records, documents, '
          'clinics and QR pages, and can’t be undone.',
    ),
  ]),
];
