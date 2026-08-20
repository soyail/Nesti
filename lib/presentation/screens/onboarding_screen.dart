import 'package:flutter/material.dart';

import '../controllers/nesti_controller.dart';
import '../theme/nesti_theme.dart';
import '../widgets/nesti_pet.dart';
import '../widgets/paper_backdrop.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final NestiController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  int _step = 0;
  bool _greeting = true;
  bool _hydration = true;
  bool _movement = true;
  bool _reduceMotion = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _CompanionPreview(
                    step: _step,
                    reduceMotion: _reduceMotion,
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 6,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 560),
                      padding: const EdgeInsets.fromLTRB(38, 34, 38, 30),
                      decoration: BoxDecoration(
                        color: NestiColors.warmWhite.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: NestiColors.ink.withValues(alpha: 0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Progress(step: _step),
                          const SizedBox(height: 28),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            child: KeyedSubtree(
                              key: ValueKey(_step),
                              child: _stepContent(context),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              if (_step > 0)
                                TextButton(
                                  onPressed: () => setState(() => _step--),
                                  child: const Text('返回'),
                                ),
                              const Spacer(),
                              FilledButton.icon(
                                key: Key(
                                  _step == 2
                                      ? 'onboarding_finish'
                                      : 'onboarding_next',
                                ),
                                onPressed: _next,
                                icon: Icon(
                                  _step == 2
                                      ? Icons.favorite_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                                label: Text(_step == 2 ? '开始相伴' : '继续'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepContent(BuildContext context) => switch (_step) {
    0 => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('你好，我是栖伴。', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 14),
        Text(
          '我会住在桌边，安静陪你工作；在合适的时候，给一点简短、可以忽略的关心。',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        TextField(
          key: const Key('display_name_field'),
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '我该怎么称呼你？（可跳过）',
            hintText: '例如：小林',
          ),
        ),
        const SizedBox(height: 18),
        const _PromiseLine(
          icon: Icons.visibility_off_outlined,
          text: '不会读取屏幕正文、键入内容或剪贴板',
        ),
        const _PromiseLine(
          icon: Icons.notifications_off_outlined,
          text: '少打扰优先，拒绝和忽略都会被尊重',
        ),
      ],
    ),
    1 => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('想要怎样的陪伴？', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('每一种都能稍后单独调整。', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        _PreferenceSwitch(
          title: '每天第一次开工时问候',
          subtitle: '每天最多一次',
          value: _greeting,
          onChanged: (value) => setState(() => _greeting = value),
        ),
        _PreferenceSwitch(
          title: '偶尔提醒喝水',
          subtitle: '默认约 75 分钟，遵守勿扰与冷却',
          value: _hydration,
          onChanged: (value) => setState(() => _hydration = value),
        ),
        _PreferenceSwitch(
          title: '久坐时建议活动一下',
          subtitle: '默认不高于每 90 分钟一次',
          value: _movement,
          onChanged: (value) => setState(() => _movement = value),
        ),
        _PreferenceSwitch(
          title: '减少动效',
          subtitle: '关闭呼吸浮动等非必要动画',
          value: _reduceMotion,
          onChanged: (value) => setState(() => _reduceMotion = value),
        ),
      ],
    ),
    _ => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('控制权一直在你手里。', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
          '这个原型只使用本地模拟数据，不申请敏感桌面权限，也不会把对话发到外部服务。',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        const _ControlCard(
          icon: Icons.pause_circle_outline_rounded,
          title: '随时暂停',
          detail: '主动关怀和桌面感知可以分别暂停。',
        ),
        const _ControlCard(
          icon: Icons.delete_outline_rounded,
          title: '可以删除',
          detail: '设置里提供原型数据清除入口，不用担心它舍不得。',
        ),
        const _ControlCard(
          icon: Icons.lock_outline_rounded,
          title: '本地优先',
          detail: '真实 LLM 与加密存储会在方案确认后再接入。',
        ),
      ],
    ),
  };

  Future<void> _next() async {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }
    await widget.controller.completeOnboarding(
      displayName: _nameController.text,
      hydrationEnabled: _hydration,
      movementEnabled: _movement,
      greetingEnabled: _greeting,
      reduceMotion: _reduceMotion,
    );
  }
}

class _CompanionPreview extends StatelessWidget {
  const _CompanionPreview({required this.step, required this.reduceMotion});

  final int step;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NestiPet(size: 280, reduceMotion: reduceMotion, celebrating: step == 2),
        const SizedBox(height: 20),
        Text('栖于桌边，伴你工作。', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 7),
        Text(
          'Your little companion through the workday.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: NestiColors.muted),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index <= step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 5,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            decoration: BoxDecoration(
              color: active ? NestiColors.moss : const Color(0xFFE1E3DA),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _PromiseLine extends StatelessWidget {
  const _PromiseLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: NestiColors.moss),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
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

class _ControlCard extends StatelessWidget {
  const _ControlCard({
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NestiColors.mist.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: NestiColors.moss),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(detail),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
