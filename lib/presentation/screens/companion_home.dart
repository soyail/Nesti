import 'package:flutter/material.dart';

import '../../domain/care_action.dart';
import '../../domain/chat_message.dart';
import '../controllers/nesti_controller.dart';
import '../theme/nesti_theme.dart';
import '../widgets/care_bubble.dart';
import '../widgets/nesti_pet.dart';
import '../widgets/paper_backdrop.dart';

class CompanionHome extends StatelessWidget {
  const CompanionHome({super.key, required this.controller});
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                _Header(controller: controller),
                const SizedBox(height: 18),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 860) {
                        return Column(
                          children: [
                            Expanded(
                              flex: 5,
                              child: _Stage(controller: controller),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              flex: 4,
                              child: _SidePanel(controller: controller),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: _Stage(controller: controller),
                          ),
                          const SizedBox(width: 18),
                          SizedBox(
                            width: 380,
                            child: _SidePanel(controller: controller),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: NestiColors.moss,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.spa_rounded, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('栖伴 Nesti', style: Theme.of(context).textTheme.titleLarge),
            Text(
              controller.quietStatus,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: NestiColors.muted),
            ),
          ],
        ),
        const Spacer(),
        _StatusChip(
          icon: controller.context.doNotDisturb
              ? Icons.do_not_disturb_on_outlined
              : Icons.circle,
          label: controller.context.doNotDisturb ? '勿扰中' : '低干扰',
          active: controller.context.doNotDisturb,
        ),
        const SizedBox(width: 8),
        _HeaderButton(
          key: const Key('home_button'),
          icon: Icons.home_outlined,
          tooltip: '回到栖伴',
          selected: controller.panel == CompanionPanel.home,
          onPressed: () => controller.showPanel(CompanionPanel.home),
        ),
        _HeaderButton(
          key: const Key('chat_button'),
          icon: Icons.chat_bubble_outline_rounded,
          tooltip: '聊两句',
          selected: controller.panel == CompanionPanel.chat,
          onPressed: () => controller.showPanel(CompanionPanel.chat),
        ),
        _HeaderButton(
          key: const Key('settings_button'),
          icon: Icons.tune_rounded,
          tooltip: '设置与隐私',
          selected: controller.panel == CompanionPanel.settings,
          onPressed: () => controller.showPanel(CompanionPanel.settings),
        ),
      ],
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.controller});
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 32,
            right: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.preferences.displayName}，今天也不用一直用力。',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '我会在这里待着，需要时点右上角来找我。',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: NestiColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  key: const Key('evaluate_care'),
                  tooltip: '重新评估是否适合关怀',
                  onPressed: controller.evaluateCare,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NestiPet(
                    size: 245,
                    reduceMotion: controller.preferences.reduceMotion,
                    celebrating:
                        controller.currentCare?.type == CareType.celebration,
                  ),
                  const SizedBox(height: 4),
                  if (controller.currentCare != null)
                    CareBubble(
                      key: ValueKey(controller.currentCare!.id),
                      action: controller.currentCare!,
                      onAction: controller.actOnCare,
                    )
                  else
                    _QuietCard(status: controller.quietStatus),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 26,
            bottom: 22,
            child: _TinyNote(icon: Icons.shield_outlined, text: '原型模式 · 不上传对话'),
          ),
        ],
      ),
    );
  }
}

class _QuietCard extends StatelessWidget {
  const _QuietCard({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: NestiColors.warmWhite.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.air_rounded, size: 17, color: NestiColors.moss),
          const SizedBox(width: 8),
          Text(status),
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.controller});
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NestiColors.warmWhite.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: NestiColors.ink.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 190),
        child: switch (controller.panel) {
          CompanionPanel.home => _TodayPanel(
            key: const ValueKey('today'),
            controller: controller,
          ),
          CompanionPanel.chat => _ChatPanel(
            key: const ValueKey('chat'),
            controller: controller,
          ),
          CompanionPanel.settings => _SettingsPanel(
            key: const ValueKey('settings'),
            controller: controller,
          ),
        },
      ),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({super.key, required this.controller});
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今天的小角落', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            '没有打卡，也没有分数。只是把控制放在手边。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: NestiColors.muted),
          ),
          const SizedBox(height: 22),
          _QuickControl(
            icon: Icons.do_not_disturb_on_outlined,
            title: '勿扰模式',
            subtitle: '现在不显示主动气泡',
            value: controller.context.doNotDisturb,
            onChanged: controller.setDoNotDisturb,
          ),
          _QuickControl(
            icon: Icons.notifications_paused_outlined,
            title: '暂停主动关怀',
            subtitle: '保留聊天和宠物陪伴',
            value: controller.preferences.carePaused,
            onChanged: controller.setCarePaused,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 14),
          Text('随手聊一句', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PromptChip(label: '今天有点累', controller: controller),
              _PromptChip(label: '我刚完成一件事', controller: controller),
              _PromptChip(label: '陪我安静工作', controller: controller),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: NestiColors.mist.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 19,
                  color: NestiColors.moss,
                ),
                SizedBox(width: 10),
                Expanded(child: Text('当前使用离线回复与粗粒度模拟状态，不读取前台应用或屏幕内容。')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({super.key, required this.controller});
  final NestiController controller;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
          child: Row(
            children: [
              Text('聊两句', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              const _StatusChip(
                icon: Icons.cloud_off_outlined,
                label: '离线模式',
                active: false,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: widget.controller.messages.isEmpty
              ? const _EmptyChat()
              : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: widget.controller.messages.length,
                  itemBuilder: (context, index) => _MessageBubble(
                    message: widget.controller.messages[index],
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('chat_input'),
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: '想说什么都可以……'),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: const Key('send_message'),
                tooltip: '发送',
                onPressed: widget.controller.isReplying ? null : _send,
                icon: widget.controller.isReplying
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final value = _textController.text;
    _textController.clear();
    await widget.controller.sendMessage(value);
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({super.key, required this.controller});
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      children: [
        Text('设置与隐私', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 5),
        Text(
          '每一项都能解释，也能关掉。',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: NestiColors.muted),
        ),
        const SizedBox(height: 20),
        const _SectionLabel('主动关怀'),
        _SettingsSwitch(
          key: const Key('greeting_setting'),
          title: '开工问候',
          subtitle: '每天最多一次',
          value: controller.preferences.greetingEnabled,
          onChanged: (value) =>
              controller.setReminderEnabled(CareType.greeting, value),
        ),
        _SettingsSwitch(
          key: const Key('hydration_setting'),
          title: '喝水关怀',
          subtitle: '默认约 75 分钟',
          value: controller.preferences.hydrationEnabled,
          onChanged: (value) =>
              controller.setReminderEnabled(CareType.hydration, value),
        ),
        _SettingsSwitch(
          key: const Key('movement_setting'),
          title: '活动关怀',
          subtitle: '默认不高于每 90 分钟一次',
          value: controller.preferences.movementEnabled,
          onChanged: (value) =>
              controller.setReminderEnabled(CareType.movement, value),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('感知与表现'),
        _SettingsSwitch(
          key: const Key('sensing_setting'),
          title: '暂停桌面感知',
          subtitle: '原型仅使用粗粒度模拟状态',
          value: controller.preferences.sensingPaused,
          onChanged: controller.setSensingPaused,
        ),
        _SettingsSwitch(
          key: const Key('motion_setting'),
          title: '减少动效',
          subtitle: '停止非必要的呼吸浮动',
          value: controller.preferences.reduceMotion,
          onChanged: controller.setReduceMotion,
        ),
        const SizedBox(height: 16),
        const _SectionLabel('数据'),
        const _InfoRow(
          icon: Icons.folder_outlined,
          title: '数据位置',
          detail: '当前原型仅保存在进程内存中，退出后不保留。',
        ),
        const _InfoRow(
          icon: Icons.cloud_off_outlined,
          title: '外部上传',
          detail: '已关闭。聊天使用本地规则回复。',
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const Key('delete_data'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFA24337),
          ),
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('清除全部原型数据'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除全部原型数据？'),
        content: const Text('这会清除当前会话和提醒历史。设置会保留，操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('confirm_delete_data'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFA24337),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.deletePrototypeData();
  }
}

class _QuickControl extends StatelessWidget {
  const _QuickControl({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 8, 7, 8),
      decoration: BoxDecoration(
        color: value
            ? NestiColors.mist.withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: NestiColors.moss),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.controller});
  final String label;
  final NestiController controller;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.arrow_outward_rounded, size: 15),
      onPressed: () => controller.sendMessage(label),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 38,
            color: NestiColors.leaf,
          ),
          const SizedBox(height: 13),
          Text('我在听。', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text(
            '不需要把话组织得很完整。\n当前回复完全离线。',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: NestiColors.muted),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final user = message.role == ChatRole.user;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: user ? NestiColors.moss : NestiColors.mist,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(user ? 18 : 5),
            bottomRight: Radius.circular(user ? 5 : 18),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: user ? Colors.white : NestiColors.ink,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: NestiColors.moss, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: NestiColors.moss),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.active,
  });
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFF4D8CC)
            : Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: active ? 15 : 8,
            color: active ? const Color(0xFFA24337) : NestiColors.leaf,
          ),
          const SizedBox(width: 7),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: IconButton(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: selected
              ? NestiColors.moss
              : Colors.white.withValues(alpha: 0.5),
          foregroundColor: selected ? Colors.white : NestiColors.ink,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _TinyNote extends StatelessWidget {
  const _TinyNote({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: NestiColors.muted),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: NestiColors.muted),
        ),
      ],
    );
  }
}
