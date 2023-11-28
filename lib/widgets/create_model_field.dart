import 'package:flutter/material.dart';

class CreateModelField extends StatelessWidget {
  const CreateModelField({
    super.key,
    required this.fieldLabel,
    required this.description,
    required this.valueCustomizationBuilder,
    this.optional = false,
    this.selected = false,
    this.onSelect,
  });

  final String fieldLabel;
  final String description;
  final Function(BuildContext context) valueCustomizationBuilder;
  final bool optional;
  final bool selected;
  final Function(bool)? onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (optional) ...[
              IconButton(
                onPressed: () {
                  onSelect?.call(selected);
                },
                icon: selected
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.circle_outlined,
                      ),
              ),
              const SizedBox(
                width: 4,
              ),
            ],
            Text(
              fieldLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        if (optional == false || selected) ...[
          const SizedBox(
            height: 8,
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.65,
                ),
          ),
          valueCustomizationBuilder(context),
          const SizedBox(
            height: 32,
          ),
        ],
      ],
    );
  }
}
