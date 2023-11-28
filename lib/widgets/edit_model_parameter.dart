import 'package:flutter/material.dart';

class EditModelParameter extends StatelessWidget {
  const EditModelParameter({
    super.key,
    required this.parameterLabel,
    required this.description,
    required this.valueCustomizationBuilder,
    this.optional = false,
    this.selected = false,
    this.onSelect,
  });

  final String parameterLabel;
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
                        color: Colors.blueGrey,
                      ),
              ),
              const SizedBox(
                width: 4,
              ),
            ],
            Text(
              parameterLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.65,
              ),
        ),
        if (optional == false || selected) ...[
          const SizedBox(
            height: 12,
          ),
          valueCustomizationBuilder(context),
        ],
        const SizedBox(
          height: 32,
        ),
      ],
    );
  }
}
