import 'package:flutter/material.dart';

import '../../domain/care_action.dart';
import '../../domain/care_interaction.dart';
import '../theme/nesti_theme.dart';

class CareBubble extends StatelessWidget {
  const CareBubble({super.key, required this.action, required this.onAction});

  final CareAction action;
  final ValueChanged<CareOutcome> onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: '${action.suggestedMessage}。出现原因：${action.reason}',
      child: Container(
        width: 390,
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 15),
        decoration: BoxDecoration(
          color: NestiColors.warmWhite.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: NestiColors.ink.withValues(alpha: 0.11),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _TypePill(type: action.type),
                const Spacer(),
                Tooltip(
                  message: '这次先忽略',
                  child: IconButton(
                    key: const Key('ignore_care'),
                    onPressed: () => onAction(CareOutcome.ignored),
                    icon: const Icon(Icons.close_rounded, size: 19),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              action.suggestedMessage,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  key: const Key('complete_care'),
                  onPressed: () => onAction(CareOutcome.completed),
                  child: Text(_completeLabel(action.type)),
                ),
                OutlinedButton(
                  key: const Key('snooze_care'),
                  onPressed: () => onAction(CareOutcome.snoozed),
                  child: const Text('稍后提醒'),
                ),
                TextButton(
                  key: const Key('disable_care_type'),
                  onPressed: () => onAction(CareOutcome.typeDisabled),
                  child: const Text('关闭这类'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '为什么出现：${action.reason}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: NestiColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  String _completeLabel(CareType type) => switch (type) {
    CareType.hydration => '喝过啦',
    CareType.movement => '起来走走',
    CareType.greeting => '一起开始',
    _ => '知道啦',
  };
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});

  final CareType type;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (type) {
      CareType.hydration => (Icons.water_drop_outlined, '喝水关怀'),
      CareType.movement => (Icons.directions_walk_rounded, '活动关怀'),
      CareType.greeting => (Icons.wb_sunny_outlined, '今日问候'),
      _ => (Icons.spa_outlined, '轻声提醒'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: NestiColors.mist,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: NestiColors.mossDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: NestiColors.mossDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
